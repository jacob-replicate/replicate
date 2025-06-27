class SendMessageWorker
  include Sidekiq::Worker

  def perform(conversation_id, message, user_id = nil)
    conversation = Conversation.find_by(id: conversation_id)
    return if conversation.blank?

    message = conversation.messages.create!(
      content: message,
      user: User.find_by(id: user_id)
    )

    unless conversation.messages.count == 1
      ConversationChannel.broadcast_to(conversation, { message: message.content, user_submitted: message.user.present? })
    end

    if message.user.present?
      response_prompt_code = conversation.messages.count == 1 ? "landing_page_incident" : "respond_to_user_message"
      ReplyToMessageWorker.perform_async(message.id, response_prompt_code)
    end
  end
end