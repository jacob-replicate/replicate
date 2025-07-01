class SendWebMessageWorker
  include Sidekiq::Worker

  def perform(conversation_id, message, user_generated = false)
    conversation = Conversation.find_by(id: conversation_id)
    return if conversation.blank?

    message = conversation.messages.create!(
      content: message,
      user_generated: user_generatedc
    )

    if conversation.web? && conversation.messages.count > 1
      ConversationChannel.broadcast_to(conversation, { message: message.content, user_submitted: message.user.present? })
    end

    if message.user.present?
      ReplyToWebMessageWorker.perform_async(message.id)
    end
  end
end