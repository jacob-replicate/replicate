module MessageGenerators
  class Coaching < MessageGenerators::Base
    def deliver_intro
      if @conversation.web?
        deliver_elements([AvatarService.brand_avatar_row(first: true), Prompts::LandingIntroduction])
        deliver_elements([AvatarService.coach_avatar_row, Prompts::CoachingIntro])
      elsif @conversation.email?
        deliver_elements([Prompts::LandingIntroduction, Prompts::CoachingIntro])
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