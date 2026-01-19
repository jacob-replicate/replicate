module MessageGenerators
  class Base
    def initialize(conversation, min_sequence = nil)
      @conversation = conversation
      @message_sequence = [min_sequence, conversation.next_message_sequence].reject(&:blank?).max
    end

    def deliver
      return if @conversation.latest_author == :assistant
      @conversation.latest_user_message.present? ? deliver_reply : deliver_intro
    end

    def deliver_intro
      raise NotImplementedError, "You must implement the deliver_intro method in your subclass"
    end

    def deliver_reply
      raise NotImplementedError, "You must implement the deliver_reply method in your subclass"
    end

    def deliver_elements(elements, user_generated = false, skip_done_message = false)
      full_response = ""

      elements.each_with_index do |element, i|
        include_p_tag = i > 0
        p_start = include_p_tag ? "<p>" : ""
        p_end = include_p_tag ? "</p>" : ""
        text = element.is_a?(String) ? element.html_safe : "#{p_start}#{element.new(context: {}, message_history: @conversation.message_history).call}#{p_end}"
        text = sanitize_response(text)
        next if text.blank?

        broadcast_to_web(message: text, type: "element", user_generated: user_generated)
        broadcast_to_web(type: "loading", user_generated: user_generated) unless i == elements.length - 1

        full_response += "#{text}\n"
      end

      return if full_response.blank?
      full_response.gsub!(/\n\z/, "")
      message = @conversation.messages.create!(content: full_response, user_generated: user_generated)

      broadcast_to_web(type: "done") unless skip_done_message

      message
    end

    def broadcast_to_web(message: "", type: "broadcast", user_generated: false)
      broadcasting_context = { type: type, sequence: @message_sequence, user_generated: user_generated }

      if message.present?
        broadcasting_context[:message] = message
      end

      ConversationChannel.broadcast_to(@conversation, broadcasting_context)
      @conversation.update!(sequence_count: @message_sequence)
      @message_sequence += 1
    end

    def sanitize_response(message)
      message.to_s.gsub(" s ", "s ").gsub(" s,", "s,").gsub("</p></p>", "</p>").squish.html_safe
    end
  end
end