module Prompts
  class ArticleIntro < Prompts::Base
    def call
      prefix = "<p class='font-semibold'>#{@conversation.context['title']}</p>"
      parse_formatted_elements(prefix: prefix)
    end
  end
end