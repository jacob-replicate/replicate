class ConversationDriverWorker
  include Sidekiq::Worker

  sidekiq_options retry: false

  def perform(conversation_id)
    conversation = Conversation.find_by(id: conversation_id)
    return if conversation.blank?
    return if conversation.channel == "email" && (conversation.recipient.blank? || !(conversation.recipient.organization.active?))
    return if conversation.latest_author == :assistant

    message_template = "MessageGenerators::#{conversation.context["conversation_type"].camelize}".constantize.new(conversation)
    message_template.deliver
  end
end