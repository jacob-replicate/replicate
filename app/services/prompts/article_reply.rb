module Prompts
  class ArticleReply < Prompts::Base
    def call
      parse_formatted_elements
    end
  end
end