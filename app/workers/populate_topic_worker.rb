class PopulateTopicWorker
  include Sidekiq::Worker

  sidekiq_options retry: false

  def perform(topic_id)
    @topic = Topic.find(topic_id)

    generation_intents.each do |generation_intent|
      GenerateConversation.new(@topic.id, generation_intent).call
    rescue StandardError => e
      Rails.logger.error("Failed to generate for intent '#{generation_intent}': #{e.message}")
      nil
    end
  ensure
    @topic.update!(state: "populated")
  end

  private

  def generation_intents
    existing_conversations = @topic.conversations.templates.pluck(:name, :generation_intent)

    context = {
      topic_name: @topic.name,
      topic_description: @topic.description,
      existing_conversations: existing_conversations.map { |name, intent| "- #{name}: #{intent}" }.join("\n")
    }

    response = Prompts::GenerateTopicConversationIntents.new(context: context).call
    response["generation_intents"] || []
  end
end