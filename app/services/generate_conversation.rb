class GenerateConversation
  def initialize(topic_id, generation_intent)
    @topic = Topic.find_by(id: topic_id)
    @generation_intent = generation_intent
  end

  def call
    generate_conversation_template!
  end

  def generate_conversation_template!
    context = {
      topic_name: @topic&.name,
      topic_description: @topic&.description,
      conversation_generation_intent: @generation_intent
    }

    response = Prompts::GenerateConversationBasics.new(context: context).call

    Conversation.create!(
      topic: @topic,
      code: response["conversation_code"],
      name: response["conversation_name"],
      description: response["conversation_description"],
      generation_intent: response["refined_generation_intent"],
      template: true,
      state: "pending",
      variant: "incident",
      channel: "web"
    )
  end
end