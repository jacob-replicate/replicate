module MessageGenerators
  class LandingDemo < MessageGenerators::Base
    def deliver_intro
      deliver_elements([coach_avatar_row(first: true), Prompts::LandingIntroduction, "<hr/>"])
      deliver_elements([coach_avatar_row, "Hey #{@conversation.context["first_name"]},<br/>", Prompts::CoachingIntro])
      deliver_elements([student_avatar_row, Prompts::LandingConversation], true)
      deliver_elements([coach_avatar_row, Prompts::CoachingReply])
      deliver_elements([student_avatar_row, Prompts::LandingConversation], true)
      deliver_elements([coach_avatar_row, Prompts::CoachingReply])
      deliver_elements([student_avatar_row, Prompts::LandingConversation], true)
      deliver_elements([coach_avatar_row, Prompts::CoachingReply])
      deliver_elements([student_avatar_row, Prompts::LandingClosure], true)
    end
  end
end