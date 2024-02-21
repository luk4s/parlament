require "rails_helper"

RSpec.describe ParlamentState do
  subject(:state) { described_class.instance }

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
    let(:cable) { spy }

    before do
      allow(ActionCable).to receive(:server).and_return(cable)
      allow(redis).to receive(:get)
      allow(redis).to receive(:set)
      allow(state).to receive_messages(line1_text: "line1", line2_text: "line2")
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
      allow(redis).to receive(:get).with("parlament_presence").and_return("true")
      state.presence = true
      expect(redis).to have_received(:set).with("parlament_presence", "true")
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

  shared_examples "line_text" do |method, line|
    subject(:line_text) { state.send(method) }

    let(:page) { instance_double(Spina::Page, content: ) }
    let(:content) { "some text" }

    context "with state = on" do
      before do
        allow(Spina::Page).to receive(:find_by!).with(name: "state_on").and_return(page)
        allow(redis).to receive(:get).with("parlament_presence").and_return("true")
      end

      it { is_expected.to eq(content) }

      it "call properly line" do
        line_text
        expect(page).to have_received(:content).with(line)
      end
    end

    context "with state = off" do
      before do
        allow(Spina::Page).to receive(:find_by!).with(name: "state_off").and_return(page)
        allow(redis).to receive(:get).with("parlament_presence").and_return("false")
      end

      it { is_expected.to eq(content) }

      it "call properly line" do
        line_text
        expect(page).to have_received(:content).with(line)
      end
    end
  end

  it_behaves_like "line_text", :line1_text, :line1
  it_behaves_like "line_text", :line2_text, :line2
end
