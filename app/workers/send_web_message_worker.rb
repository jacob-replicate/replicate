class SendWebMessageWorker
  include Sidekiq::Worker

  def perform(conversation_id, message, user_id = nil)
    conversation = Conversation.find_by(id: conversation_id)
    return if conversation.blank?

    message = conversation.messages.create!(
      content: message,
      user: User.find_by(id: user_id)
    )

    if conversation.web? && conversation.messages.count > 1
      ConversationChannel.broadcast_to(conversation, { message: message.content, user_submitted: message.user.present? })
    end

    if message.user.present?
      ReplyToWebMessageWorker.perform_async(message.id)
    end
  end
end