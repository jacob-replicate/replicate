module MessageGenerators
  class LandingDemo < MessageGenerators::Base
    def deliver_intro
      student_avatar_row = AvatarService.student_avatar_row(@conversation.context["engineer_name"])
      deliver_elements([AvatarService.brand_avatar_row(first: true, name: "Overview"), Prompts::LandingIntroduction])
      deliver_elements([AvatarService.coach_avatar_row + "<div class='prompt-output'>Hey #{@conversation.context["first_name"]},</div>", Prompts::CoachingIntro])
      deliver_elements([student_avatar_row, Prompts::LandingConversation], true)
      deliver_elements([AvatarService.coach_avatar_row, Prompts::CoachingReply])
      deliver_elements([student_avatar_row, Prompts::LandingConversation], true)
      deliver_elements([AvatarService.coach_avatar_row, Prompts::CoachingReply])
      deliver_elements([student_avatar_row, Prompts::LandingConversation], true)
      deliver_elements([AvatarService.coach_avatar_row, Prompts::CoachingReply])
      deliver_elements([student_avatar_row, Prompts::LandingClosure], true)
      deliver_elements([AvatarService.brand_avatar_row + "<div class='mt-2'>Want coaching like this in your team's inbox every Monday?</div><div class='mt-2'>Paste your engineers' emails below. You can always update the list later.</div><div class='mt-2'>Your first full calendar month is free. I'll send you an email after to see if you want to continue.</div>"])
      broadcast_to_web(type: "show_cta")
    end

    def email_form

    end
  end
end