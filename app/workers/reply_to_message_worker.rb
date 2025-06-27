class ReplyToMessageWorker
  include Sidekiq::Worker

  def perform(message_id, prompt_name = :respond_to_user_message)
    message = Message.find_by(id: message_id)
    return if message.blank? || message.user.blank?

    response = Prompt.new(prompt_name, input: { message: message.content }, history: message.conversation.message_history).execute
    if response.present?
      SendMessageWorker.perform_async(message.conversation.id, response)
    end
  end
end