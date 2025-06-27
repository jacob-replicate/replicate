class SendMessageWorker
  include Sidekiq::Worker

  def perform(conversation_id, message, user_id = nil)
    conversation = Conversation.find_by(id: conversation_id)
    return if conversation.blank?

    message = conversation.messages.create!(
      content: message,
      user: User.find_by(id: user_id)
    )

    if message.user.present?
      response = Prompt.new(:respond_to_user_message, input: { message: message.content }, history: conversation.message_history).execute

      if response.present?
        SendMessageWorker.perform_async(conversation.id, response)
      else
        raise
      end
    end
  end
end