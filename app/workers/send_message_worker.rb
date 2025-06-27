class SendMessageWorker
  include Sidekiq::Worker

  def perform(conversation_id, message, user_id)
    conversation = Conversation.find_by(id: conversation.id)
    return if conversation.blank?

    message = conversation.messages.create!(
      content: message,
      state: :sent,
      user: User.find_by(id: user_id)
    )

    SummarizeMessageWorker.perform_async(message.id)

    if message.user.present?
      response_prompt_code = Prompt.new(:fetch_relevant_response_prompt, input: { conversation: conversation, message: message.content }).execute

      if response_prompt_code.present?
        response = Prompt.new(response_prompt_code, input: { message: message.content }).execute
        SendMessageWorker.perform_async(conversation.id, response)
      end
    end
  end
end