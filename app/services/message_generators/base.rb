module MessageGenerators
  class Base
    def initialize(conversation)
      @conversation = conversation
      @context = conversation.context || {}
    end

    def deliver
    end



    def send_system_message_web(conversation)
      if service_class.present?
        if service_class.stream?
        else
          message = service_class.new(conversation: conversation).call
          Message.create!(conversation: conversation, content: message, user_generated: false)
          ConversationChannel.broadcast_to(conversation, { message: message, user_generated: false, type: "stream" })
          ConversationChannel.broadcast_to(conversation, { type: "done" })
        end
      else
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
  end
end