class SendWebMessageWorker
  include Sidekiq::Worker

  def perform(conversation_id, message, user_generated = false)
    conversation = Conversation.find_by(id: conversation_id)
    return if conversation.blank?

    message = conversation.messages.create!(
      content: message,
      user_generated: user_generated
    )

    if conversation.web?
      ConversationChannel.broadcast_to(conversation, { message: message.content, user_generated: message.user_generated })
    end

    if message.user_generated
      ReplyToWebMessageWorker.perform_async(message.id)
    end
  end
end