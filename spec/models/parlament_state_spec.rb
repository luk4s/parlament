require "rails_helper"

RSpec.describe ParlamentState do
  subject(:state) { singleton_class_proxy.instance }

  let(:singleton_class_proxy) { Class.new(described_class) }
  let(:redis) { instance_double(Redis) }

  before do
    allow(Redis).to receive(:new).and_return(redis)
  end

  describe "#presence" do
    subject(:presence) { state.presence }

    context "when presence is set to true in Redis" do
      before do
        allow(redis).to receive(:get).with("parlament_presence").and_return("true")
      end

      it { is_expected.to be true }
    end

    context "when presence is set to false in Redis" do
      before do
        allow(redis).to receive(:get).with("parlament_presence").and_return(nil)
      end

      it { is_expected.to be false }
    end
  end

  describe "#presence=" do
    before do
      allow(redis).to receive(:get)
      allow(redis).to receive(:set)
      allow(state).to receive(:broadcast!)
    end

    it "sets presence to true in Redis" do
      state.presence = true
      expect(redis).to have_received(:set).with("parlament_presence", "true")
    end

    it "sets presence to false in Redis" do
      state.presence = false
      expect(redis).to have_received(:set).with("parlament_presence", "false")
    end

    it "broadcasts presence change to Redis" do
      state.presence = true
      expect(state).to have_received(:broadcast!)
    end
  end

  describe "#broadcast!" do
    let(:cable) { spy }

    before do
      allow(ActionCable).to receive(:server).and_return(cable)
      allow(state).to receive_messages(presence: true, line1_text: "line1", line2_text: "line2")
    end

    it "broadcasts presence change to Redis" do
      state.broadcast!
      expect(cable).to have_received(:broadcast).with "parlament_presence_channel", hash_including(presence: true)
    end
  end

  describe "#as_json" do
    subject(:json) { state.as_json }

    before do
      allow(state).to receive_messages(presence: true, line1_text: "line1", line2_text: "line2")
    end

    it "returns a hash with presence and line text" do
      expect(json).to eq(presence: true, line1_text: "line1", line2_text: "line2")
    end
  end

  describe "line_texts" do
    subject(:line1_text) { state.line1_text }

    let(:page) { instance_double(Spina::Page, title:, content:) }
    let(:title) { "Page title" }
    let(:content) { "Page content" }

    before do
      allow(state).to receive(:presence_state).and_return("on")
      allow(Spina::Page).to receive(:find_by!).and_return(page)
    end

    it "line1 returns the title of the page" do
      expect(line1_text).to eq(title)
    end

    it "line2 return content of the page" do
      expect(state.line2_text).to eq(content)
    end
  end
end
