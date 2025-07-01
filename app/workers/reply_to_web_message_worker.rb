class ReplyToWebMessageWorker
  include Sidekiq::Worker

  def perform(message_id, prompt_code = nil)
    message = Message.find_by(id: message_id)
    return if message.blank? || !(message.user_generated)

    conversation = message.conversation
    full_response = ""

    flusher = MarkdownFlusher.new do |chunk|
      full_response << chunk
      Rails.logger.silence { ConversationChannel.broadcast_to(conversation, { message: chunk, user_generated: false, type: "stream" }) }
    end

    Prompt.new(prompt_code || conversation.reply_prompt_code, input:  { message: message.content }, history: conversation.message_history).stream do |token|
      flusher << token
    end

    flusher.final_flush!

    Message.create!(conversation: conversation, content: full_response, user_generated: false)

    if conversation.web?
      ConversationChannel.broadcast_to(conversation, { type: "done" })
    end
  end
end