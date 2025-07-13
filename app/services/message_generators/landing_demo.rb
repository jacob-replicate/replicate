module MessageGenerators
  class LandingDemo < MessageGenerators::Base
    def deliver_reply
      if @conversation.messages.count == 1
        deliver_elements([avatar_row, Prompts::LandingIntro])
      else
        if latest_user_message == "1"
          deliver_elements([avatar_row, Prompts::ExampleReport])
        else
          deliver_elements([avatar_row, Prompts::LandingReply])
        end
      end
    end
  end
end