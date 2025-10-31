module Prompts
  class CoachingIntro < Prompts::Base
    def call
      classes = (@conversation.present? && @conversation.web?) ? " class='font-semibold'" : ""
      question = "<p style='margin-top: 30px; font-size: 17px'><b#{classes}>What's your first move here?</b></p>".html_safe
      parse_formatted_elements(suffix: question)
    end
  end
end