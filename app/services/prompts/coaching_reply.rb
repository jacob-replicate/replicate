module Prompts
  class CoachingIntro < Prompts::Base
    def call
      intro_paragraph = fetch_valid_response
      return "" if intro_paragraph.nil?

      intro_paragraph + " #{questions.sample}"
    end
  end
end