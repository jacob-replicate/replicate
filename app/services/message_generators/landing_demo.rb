module MessageGenerators
  class LandingDemo < MessageGenerators::Base
    def deliver_intro
      student_avatar_row = AvatarService.student_avatar_row(@conversation.context["engineer_name"])
      deliver_elements([AvatarService.brand_avatar_row(first: true, name: "Jacob Comer", photo_path: "jacob-square.jpg"), Prompts::LandingIntroduction])
      deliver_elements([AvatarService.coach_avatar_row + "<div class='prompt-output'>Hey #{@conversation.context["first_name"]},</div>", Prompts::CoachingIntro])
      deliver_elements([student_avatar_row, Prompts::LandingConversation], true)
      deliver_elements([AvatarService.coach_avatar_row, Prompts::CoachingReply])
      deliver_elements([student_avatar_row, Prompts::LandingConversation], true)
      deliver_elements([AvatarService.coach_avatar_row, Prompts::CoachingReply])
      deliver_elements([student_avatar_row, Prompts::LandingConversationWrong], true)
      deliver_elements([AvatarService.coach_avatar_row, Prompts::CoachingReply])
      deliver_elements([student_avatar_row, Prompts::LandingClosure], true)
      broadcast_to_web(type: "show_cta")
    end
  end
end