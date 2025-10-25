module Prompts
  class CoachingIntro < Prompts::Base
    def call
      intro_paragraph = SanitizeAiContent.call(fetch_raw_output)
      return "" if intro_paragraph.nil?

      classes = (@conversation.present? && @conversation.web?) ? " class='font-medium'" : ""
      intro_paragraph + "<p><b#{classes}>What's your first move here?</b></p>".html_safe
    end
  end
end