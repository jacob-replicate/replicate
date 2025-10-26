module Prompts
  class CoachingReply < Prompts::Base
    def call
      30.times do
        raw_json = JSON.parse(fetch_raw_output) rescue {}
        raw_json = raw_json.with_indifferent_access

        if Array(raw_json["paragraphs"]).any?
          formatted_paragraphs = raw_json["paragraphs"].map do |content|
            "<p>#{content}</p>".html_safe
          end

          return formatted_paragraphs.join
        end
      end
    end
  end
end