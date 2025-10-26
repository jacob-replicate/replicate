module Prompts
  class ArticleIntro < Prompts::Base
    def call
      30.times do
        raw_json = JSON.parse(fetch_raw_output) rescue {}
        raw_json = raw_json.with_indifferent_access

        if Array(raw_json["paragraphs"]).any?
          return (["<p class='font-semibold'>#{@conversation.context['title']}</p>"] + raw_json["paragraphs"].map { |content| "<p>#{content}</p>" }).join("\n").html_safe
        end
      end
    end
  end
end