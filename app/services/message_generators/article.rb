module MessageGenerators
  class Article < MessageGenerators::Base
    def deliver_intro
      broadcast_to_web(type: "loading", user_generated: false)
      reply = Prompts::ArticleIntro.new(conversation: @conversation).call + "<p class='font-semibold'>#{ctas.sample}</span>"
      broadcast_to_web(type: "element", message: reply, user_generated: false)
      @conversation.messages.create!(content: "#{reply}", user_generated: false)
      deliver_multiple_choice_options(3)
      broadcast_to_web(type: "done")
    end

    def deliver_reply
      broadcast_to_web(type: "element", message: AvatarService.coach_avatar_row, user_generated: false)
      broadcast_to_web(type: "loading", user_generated: false)
      reply = Prompts::ArticleReply.new(conversation: @conversation).call + "<p style='margin-top: 20px; font-size: 17px' class='font-semibold'>#{ctas.sample}</span>"
      broadcast_to_web(type: "element", message: reply, user_generated: false)
      @conversation.messages.create!(content: "<p>#{AvatarService.coach_avatar_row}</p>#{reply}", user_generated: false)
      deliver_multiple_choice_options(3)
      broadcast_to_web(type: "done")
    end

    private

    def deliver_multiple_choice_options(count)
      3.times do
        options = Prompts::MultipleChoiceOptionsArticle.new(conversation: @conversation, context: { max: count }).call

        if options.any?
          broadcast_to_web(message: options, type: "multiple_choice", user_generated: false)
          return
        end
      end
    end

    def ctas
      [
        "What path do you want to go down?",
        "Where should we take this next?",
        "What do you want to dive into?",
        "Which thread should we pull on?",
        "What angle do you want to explore?",
        "Where do you want to focus next?",
        "Where do you want to zoom in?"
      ]
    end
  end
end