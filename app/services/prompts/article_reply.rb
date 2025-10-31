module Prompts
  class ArticleReply < Prompts::Base
    def call
      parse_formatted_paragraphs
    end
  end
end