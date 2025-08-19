class ConversationDriverWorker
  include Sidekiq::Worker

  sidekiq_options retry: false, lock: :until_executed

  def perform(conversation_id, message_body = nil)
    conversation = Conversation.find_by(id: conversation_id)
    return if conversation.blank?
    return if conversation.channel == "email" && !(conversation.recipient.organization.active?)

    message_template = "MessageGenerators::#{conversation.context["conversation_type"].camelize}".constantize.new(conversation)
    message_template.deliver
  end
end