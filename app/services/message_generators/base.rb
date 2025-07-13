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
    def deliver_elements(elements)
      full_response = ""

      elements.each_with_index do |element, i|
        text = element.is_a?(String) ? element : element.new(conversation: @conversation).call
        next if text.blank? # TODO: Add error handling for empty elements

        if @conversation.web?
          broadcast_to_web(message: text, type: "element")
          broadcast_to_web(type: "loading") unless i == elements.length - 1
        end

        full_response += "#{text}\n"
      end

      broadcast_to_web(type: "done")
      @conversation.messages.create!(content: full_response, user_generated: false)

      if @conversation.email?
        # TODO: Send it via another DeliverEmailWorker.perform_async(@conversation.id)
      end
    end

    def avatar_row
      "<div class='flex items-center mb-2 gap-3'><div style='width: 32px'><img src='/jacob-square.jpg' class='rounded-full' /></div><div class='font-medium'>Jacob Comer</div></div>"
    end

    def broadcast_to_web(message: "", type: "broadcast")
      broadcasting_context = { type: type, sequence: @message_sequence }

      if message.present?
        broadcasting_context[:message] = sanitize_response(message)
      end

      ConversationChannel.broadcast_to(@conversation, broadcasting_context)
      @message_sequence += 1
    end

    def sanitize_response(message)
      renderer = Redcarpet::Render::HTML.new(filter_html: true, hard_wrap: true)
      markdown = Redcarpet::Markdown.new(renderer, autolink: true, tables: true)
      html = markdown.render(message.gsub("<pre>", "").gsub("</pre>", ""))
      html.html_safe
    end
  end
end