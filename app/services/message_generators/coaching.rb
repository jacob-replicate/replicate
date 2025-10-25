module MessageGenerators
  class Coaching < MessageGenerators::Base
    def deliver_intro
      if @conversation.web?
        deliver_elements([AvatarService.coach_avatar_row, Prompts::CoachingIntro], false, true)
        deliver_multiple_choice_options
        broadcast_to_web(type: "done")
      elsif @conversation.email?
        elements = ["Hey there,"]

        recipient = @conversation.recipient
        if recipient&.engineer? && recipient.conversations.count == 1
          owner_name = @conversation.recipient.organization.members.find_by(role: "owner")&.name || "One of your teammates"
          elements << "<p>#{owner_name} added you to their <a href='https://replicate.info'>replicate.info</a> team. No UI. GPT just shows up in your inbox with an infra puzzle every week. The more you think out loud, the more it can help uncover your blind spots (before production does).</p>"
        end

        elements << Prompts::CoachingIntro
        elements << unsubscribe_footer(@conversation.recipient)

        deliver_elements(elements)
      end
    end

    def deliver_reply
      if @conversation.web?
        latest_message = @conversation.latest_user_message.content
        elements = [AvatarService.coach_avatar_row]
        multiple_choice = false

        if @conversation.messages.user.count == 0
          elements << Prompts::CoachingReply
          multiple_choice = true
        elsif latest_message == "Give me a hint"
          elements << Prompts::CoachingReply
          elements << ANOTHER_HINT_LINK
        elsif latest_message == "Give me another hint"
          elements << Prompts::CoachingReply
          elements << FINAL_HINT_LINK
          multiple_choice = true
        elsif latest_message == "What am I missing here?"
          elements << Prompts::CoachingExplain
          elements << HINT_LINK
        else
          elements << Prompts::CoachingReply
          elements << HINT_LINK
        end

        deliver_elements(elements, false, true)
        deliver_multiple_choice_options if multiple_choice
        broadcast_to_web(type: "done")
      elsif @conversation.email?
        deliver_elements([Prompts::CoachingReply])
      end
    end

    def deliver_multiple_choice_options
      3.times do
        options = Prompts::MultipleChoiceOptions.new(conversation: @conversation).call

        if options.any?
          broadcast_to_web(message: options, type: "multiple_choice", user_generated: false)
          return
        end
      end
    end
  end
end