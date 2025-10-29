module Prompts
  class CoachingIntro < Prompts::Base
    def call
      30.times do
        raw_json = JSON.parse(fetch_raw_output) rescue {}
        raw_json = raw_json.with_indifferent_access

        if Array(raw_json["paragraphs"]).any?
          formatted_paragraphs = raw_json["paragraphs"].map do |content|
            "<p>#{content}</p>".html_safe
          end

          classes = (@conversation.present? && @conversation.web?) ? " class='font-semibold'" : ""
          return formatted_paragraphs.join + "<p><b#{classes}>What's your first thought here?</b></p>".html_safe
        end
      end
    end
  end
end