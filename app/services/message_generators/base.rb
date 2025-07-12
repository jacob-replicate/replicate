module MessageGenerators
  class Base
    def initialize(conversation)
      @conversation = conversation
      @context = conversation.context || {}
      @message_sequence = conversation.messages.count + 1
    end

    def deliver
      return if @conversation.latest_author == :assistant

      if @conversation.latest_user_message.present?
        deliver_reply
      else
        deliver_intro
      end
    end

    def deliver_elements(elements)
      full_response = ""

      elements.each do |element|
        if element.is_a?(String)
        elsif element.is_a?(Prompt::Base)
          element_text = element.new(conversation: @conversation)
        end
      end
    end

    def avatar_row
      "<div class='flex items-center mb-3 gap-3'><div style='width: 40px'><img src='/jacob-square.jpg' class='rounded-full' /></div><div class='font-medium text-md'>Jacob Comer</div></div>"
    end

    # TODO: Pass summaries to prompt if conversation history is too long.
    def stream_prompt(prompts)
      full_response = ""

      prompts.each do |prompt|
        flusher = MarkdownFlusher.new do |chunk|
          full_response << chunk
          Rails.logger.silence { stream_to_web(message: chunk) }
        end

        Prompt.new(prompt_code, context: @conversation.context, history: @conversation.message_history).stream { |token| flusher << token }
        flusher.final_flush!
      end

      full_response
    end

    def stream_to_web(message: "", type: "stream")
      streaming_context = { type: type, sequence: @message_sequence }

      if message.present?
        streaming_context[:message] = message
      end

      ConversationChannel.broadcast_to(conversation, streaming_context)
      @message_sequence += 1

      stream_to_web(type: "loading") unless ["loading", "done"].include?(type)
    end
  end
end