class PopulateTopicWorker
  include Sidekiq::Worker

  sidekiq_options retry: false

  def perform(topic_id)
    PopulateTopic.new(topic_id).call
  end
end