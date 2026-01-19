module MessageGenerators
  class Question < MessageGenerators::Base
    def deliver_intro
      broadcast_to_web(type: "element", message: AvatarService.coach_avatar_row, user_generated: false)
      broadcast_to_web(type: "loading", user_generated: false)

      reply = Prompts::QuestionIntro.new(context: { generation_intent: @conversation.generation_intent }).call

      @conversation.messages.create!(content: "#{AvatarService.coach_avatar_row}#{reply}", user_generated: false)
      broadcast_to_web(type: "element", message: reply, user_generated: false)

      deliver_multiple_choice_options(3, reply)

      broadcast_to_web(type: "done")
    end

    def deliver_reply
      latest_message = @conversation.latest_user_message.content
      total_user_message_count = @conversation.messages.user.count
      turn = total_user_message_count + 1
      multiple_choice_options = 0
      hint_link = HINT_LINK

      broadcast_to_web(type: "element", message: AvatarService.coach_avatar_row, user_generated: false)
      broadcast_to_web(type: "loading", user_generated: false)

      custom_instructions = ""

      if latest_message == "Give me a hint"
        custom_instructions = "- The user is asking for a hint. Provide a single paragraph that clarifies the concept. End with a simple question."
        hint_link = ANOTHER_HINT_LINK
        multiple_choice_options = 3
      elsif latest_message == "Give me another hint"
        custom_instructions = "- The user needs more help. Give them a direct explanation in 1-2 short paragraphs. Be concrete about the concept they're missing."
        multiple_choice_options = 3
      elsif turn == 2
        multiple_choice_options = 2
      end

      reply = Prompts::QuestionReply.new(
        context: { custom_instructions: custom_instructions, cta: question_format },
        message_history: @conversation.message_history
      ).call

      broadcast_to_web(type: "element", message: reply, user_generated: false)

      if hint_link.present? && turn > 1
        broadcast_to_web(type: "element", message: hint_link, user_generated: false)
      end

      deliver_multiple_choice_options(multiple_choice_options, reply) if multiple_choice_options.positive?

      @conversation.messages.create!(content: "<p>#{AvatarService.coach_avatar_row}</p>#{reply}", user_generated: false)
      broadcast_to_web(type: "done")
    end

    def deliver_multiple_choice_options(count, reply)
      options = Prompts::MultipleChoiceOptions.new(
        context: { max: count, most_recent_message: reply },
        message_history: @conversation.message_history
      ).call

      if options.any?
        broadcast_to_web(message: options, type: "multiple_choice", user_generated: false)
      end
    end

    def question_format
      "- End with a single focused question under 100 characters. Not a gotcha, just a genuine probe."
    end
  end
end