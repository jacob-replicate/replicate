module MessageGenerators
  class Coaching < MessageGenerators::Base
    def deliver_intro
      if @conversation.web?
        deliver_elements([AvatarService.coach_avatar_row, Prompts::CoachingIntro])
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
        deliver_elements([AvatarService.coach_avatar_row, Prompts::CoachingReply])
      elsif @conversation.email?
        deliver_elements([Prompts::CoachingReply])
      end
    end
  end
end