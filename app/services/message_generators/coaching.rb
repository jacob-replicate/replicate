module MessageGenerators
  class Coaching < MessageGenerators::Base
    def deliver_intro
      deliver_elements([avatar_row, Prompts::CoachingIntro])
    end

    def reply
      deliver_elements([avatar_row, Prompts::CoachingReply])
    end
  end
end