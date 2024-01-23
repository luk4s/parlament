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
      allow(redis).to receive(:set)
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
      expect(cable).to have_received(:broadcast).with "parlament_presence_channel", { presence: true }
      expect(redis).to have_received(:set).with("parlament_presence", "true")
    end
  end
end
