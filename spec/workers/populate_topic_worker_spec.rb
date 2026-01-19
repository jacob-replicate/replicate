require 'rails_helper'

RSpec.describe PopulateTopicWorker, type: :worker do
  let(:topic) { create(:topic) }

  describe '#perform' do
    it 'calls PopulateTopic service with the given topic_id' do
      populate_service = instance_double(PopulateTopic)
      allow(PopulateTopic).to receive(:new).with(topic.id).and_return(populate_service)
      allow(populate_service).to receive(:call)

      described_class.new.perform(topic.id)

      expect(PopulateTopic).to have_received(:new).with(topic.id)
      expect(populate_service).to have_received(:call)
    end
  end

  describe 'sidekiq options' do
    it 'has retry disabled' do
      expect(described_class.sidekiq_options['retry']).to eq(false)
    end
  end
end