require "rails_helper"

RSpec.describe ParlamentState do
  include ActiveSupport::Testing::TimeHelpers

  subject(:state) { singleton_class_proxy.instance }

  let(:singleton_class_proxy) { Class.new(described_class) }

  before do
    state.redis.flushdb
  end

  describe "#presence=" do
    before do
      allow(state).to receive(:broadcast!)
    end

    it "sets presence to true in Redis" do
      state.presence = true

      expect(state.redis.get("parlament_presence")).to eq("true")
      expect(state.redis.get("presence_updated_at")).to eq(Time.current.to_i.to_s)
    end

    it "sets presence to false in Redis" do
      state.presence = false
      expect(state.redis.exists?("parlament_presence", "presence_updated_at")).to be true
    end

    it "broadcasts presence change to Redis" do
      state.presence = true
      expect(state).to have_received(:broadcast!)
    end
  end

  describe "#presence" do
    subject(:presence) { state.presence }

    before do
      allow(state).to receive(:broadcast!)
    end

    context "when presence is set to true in Redis" do
      it "with missing presence_updated_at" do
        expect(presence).to be false
      end

      it "with presence_updated_at and expire" do
        travel_to 4.hours.ago do
          state.presence = true
        end

        expect(presence).to be false
      end

      it "with presence_updated_at and not expire" do
        travel_to 2.minutes.ago do
          state.presence = true
        end

        expect(presence).to be true
      end
    end

    context "when presence is set to false in Redis" do
      it { is_expected.to be false }
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
