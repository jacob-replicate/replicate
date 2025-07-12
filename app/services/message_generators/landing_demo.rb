module MessageGenerators
  class LandingDemo < MessageGenerators::Base
    def deliver_reply
      if @conversation.messages.count == 1
        deliver_elements([avatar_row, Prompts::LandingIntro])
      else
        deliver_elements([avatar_row, Prompts::LandingIntro])
      end
    end
  end
end