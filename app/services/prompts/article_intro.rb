module Prompts
  class ArticleIntro < Prompts::Base
    def prefix
      "<p class='font-semibold'>#{@conversation.context['title']}</p>".html_safe
    end
  end
end