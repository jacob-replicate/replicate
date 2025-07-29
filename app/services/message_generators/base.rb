module MessageGenerators
  class Base
    def initialize(conversation)
      @conversation = conversation
      @context = conversation.context || {}
      @message_sequence = conversation.next_message_sequence
    end

    def latest_user_message
      @conversation.latest_user_message
    end

    def deliver
      return if @conversation.latest_author == :assistant

      if @conversation.latest_user_message.present?
        deliver_reply
      else
        deliver_intro
      end
    end

    def deliver_intro
      raise NotImplementedError, "You must implement the deliver_intro method in your subclass"
    end

    def deliver_reply
      raise NotImplementedError, "You must implement the deliver_reply method in your subclass"
    end

    # TODO: Add error handling for prompts that failed all retries
    def deliver_elements(elements, user_generated = false)
      full_response = ""

      elements.each_with_index do |element, i|
        text = element.is_a?(String) ? element.html_safe : "<p>#{element.new(conversation: @conversation).call}</p>"
        next if text.blank? # TODO: Add error handling for empty elements

        if @conversation.web?
          broadcast_to_web(message: text, type: "element", user_generated: user_generated)
          broadcast_to_web(type: "loading", user_generated: user_generated) unless i == elements.length - 1
        end

        full_response += "#{text}\n"
      end

      @conversation.messages.create!(content: full_response, user_generated: user_generated)

      if @conversation.web?
        broadcast_to_web(type: "done")
        @message_sequence = @conversation.next_message_sequence
      elsif @conversation.email?
        # TODO: Send it via another DeliverEmailWorker.perform_async(@conversation.id)
      end
    end

    def broadcast_to_web(message: "", type: "broadcast", user_generated: false)
      broadcasting_context = { type: type, sequence: @message_sequence, user_generated: user_generated }

      if message.present?
        broadcasting_context[:message] = sanitize_response(message)
      end

      ConversationChannel.broadcast_to(@conversation, broadcasting_context)
      @message_sequence += 1
    end

    def sanitize_response(message)
      message.gsub("<pre>", "").gsub("</pre>", "").html_safe
    end
  end
end