module MessageGenerators
  class Base
    def initialize(conversation)
      @conversation = conversation
      @context = conversation.context || {}
      @message_sequence = conversation.messages.count + 1
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
        text = element.is_a?(String) ? element.html_safe : element.new(conversation: @conversation).call
        next if text.blank? # TODO: Add error handling for empty elements

        if @conversation.web?
          broadcast_to_web(message: text, type: "element", user_generated: user_generated)
          broadcast_to_web(type: "loading") unless i == elements.length - 1
        end

        full_response += "#{text}\n"
      end

      broadcast_to_web(type: "done")
      @conversation.messages.create!(content: full_response, user_generated: user_generated)

      if @conversation.email?
        # TODO: Send it via another DeliverEmailWorker.perform_async(@conversation.id)
      end
    end

    def coach_avatar_row(first: false)
      avatar_row(first: first)
    end

    def student_avatar_row
      engineer_name = @conversation.context["engineer_name"]

      photo_id = if engineer_name.include?("Alex")
        1
      elsif engineer_name.include?("Casey")
        2
      else
        3
      end

      avatar_row(name: engineer_name, photo_path: "profile-photo-#{photo_id}.jpg")
    end

    def avatar_row(name: "Jacob Comer", photo_path: "jacob-square.jpg", first: false)
      "<div class='mb-4'><div class='flex items-center gap-3'><div style='width: 32px'><img src='/#{photo_path}' class='rounded-full' /></div><div class='font-medium'>#{name}</div></div></div>"
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