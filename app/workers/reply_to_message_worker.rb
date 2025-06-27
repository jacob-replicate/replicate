class ReplyToMessageWorker
  include Sidekiq::Worker

  def perform(message_id, prompt_name = :respond_to_user_message)
    msg = Message.find_by(id: message_id)
    return if msg.blank? || msg.user.blank?

    full_response = ""

    flusher = MarkdownFlusher.new do |chunk|
      full_response << chunk
      Rails.logger.silence do
        ConversationChannel.broadcast_to(
          msg.conversation,
          { message: chunk, user_submitted: false, type: "stream" }
        )
      end
    end

    Prompt.new(prompt_name,
      input:  { message: msg.content },
      history: msg.conversation.message_history).stream do |token|
      flusher << token
    end

    flusher.final_flush!

    Message.create!(conversation: msg.conversation, content: full_response, user: nil)

    ConversationChannel.broadcast_to(msg.conversation, { type: "done" })
  end
end