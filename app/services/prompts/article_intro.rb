module Prompts
  class ArticleIntro < Prompts::Base
    def prefix
      "<p class='font-semibold'>#{@conversation.context['title']}</p>"
    end
  end
end