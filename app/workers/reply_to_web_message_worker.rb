class ReplyToWebMessageWorker
  include Sidekiq::Worker

  def perform(conversation_id, prompt_code = nil)
    conversation = Conversation.find_by(id: conversation_id)
    return if conversation.blank?
    message = conversation.latest_user_message

    full_response = ""

    flusher = MarkdownFlusher.new do |chunk|
      full_response << chunk
      Rails.logger.silence { ConversationChannel.broadcast_to(conversation, { message: chunk, user_generated: false, type: "stream" }) }
    end

    Prompt.new(conversation.next_prompt_code, context: conversation.context, history: conversation.message_history).stream do |token|
      flusher << token
    end

    flusher.final_flush!

    Message.create!(conversation: conversation, content: full_response, user_generated: false)

    if conversation.web?
      ConversationChannel.broadcast_to(conversation, { type: "done" })
    end
  end
end