class SendMessageWorker
  include Sidekiq::Worker

  def perform(conversation_id, message = nil, user_generated = false)
    conversation = Conversation.find_by(id: conversation_id)
    return if conversation.blank?

    if user_generated
      send_user_message(conversation, message)
    else
      send_system_message(conversation)
    end
  end

  private

  def send_user_message(conversation, message)
    message = conversation.messages.create!(content: message, user_generated: true)

    ConversationChannel.broadcast_to(conversation, { message: message.content, user_generated: message.user_generated })
    SendMessageWorker.perform_async(conversation.id) # to trigger system reply
  end

  def send_system_message(conversation)
    if conversation.web?
      send_system_message_web(conversation)
    else
      # TODO: Handle this
    end
  end

  def send_system_message_web(conversation)
    full_response = ""

    flusher = MarkdownFlusher.new do |chunk|
      full_response << chunk
      Rails.logger.silence { ConversationChannel.broadcast_to(conversation, { message: chunk, user_generated: false, type: "stream" }) }
    end

    # TODO: Add summaries here, not just full message history. Maybe encapsulate that within message history and block?
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