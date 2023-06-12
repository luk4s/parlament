require 'rails_helper'

RSpec.describe ParlamentState do
  subject(:state) { described_class.instance }

  let(:redis) { instance_double(Redis) }

  before do
    allow(Redis).to receive(:new).and_return(redis)
  end

  describe '#presence' do
    subject(:presence) { state.presence }
    context 'when presence is set to true in Redis' do
      before do
        allow(redis).to receive(:get).with('parlament_presence').and_return('true')
      end

      it { is_expected.to eq true }
    end

    context 'when presence is set to false in Redis' do
      before do
        allow(redis).to receive(:get).with('parlament_presence').and_return(nil)
      end

      it { is_expected.to eq false }
    end
  end

  describe '#presence=' do
    it 'sets presence to true in Redis' do
      expect(redis).to receive(:set).with('parlament_presence', 'true')
      state.presence = true
    end

    it 'sets presence to false in Redis' do
      expect(redis).to receive(:set).with('parlament_presence', 'false')
      state.presence = false
    end
  end
end
