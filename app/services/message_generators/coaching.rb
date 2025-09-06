module MessageGenerators
  class Coaching < MessageGenerators::Base
    def deliver_intro
      if @conversation.web?
        deliver_elements([AvatarService.coach_avatar_row, Prompts::CoachingIntro])
      elsif @conversation.email?
        elements = ["<p>Hey there,</p>"]

        recipient = @conversation.recipient
        if recipient&.engineer? && recipient.conversations.count == 1
          elements << "<p>Taylor Jones signed you up for <a href='http://replicate.info'>Replicate</a>. There's no UI. GPT just shows up in your inbox with an infra puzzle every week. The more you think out loud, the more it can help uncover your blind spots (before production does).</p>"
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