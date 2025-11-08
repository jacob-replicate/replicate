module Prompts
  class ArticleIntro < Prompts::Base
    def call
      parallel_batch_process(starting_batch_size: 3) do |elements|
        paragraphs = elements.select { |e| Hash(e).with_indifferent_access[:type] == "paragraph" }.map { |e| e.with_indifferent_access[:content].to_s }
        paragraphs_not_too_long = paragraphs.all? { |p| p.length <= 500 && p.exclude?("*") }
        last_element_is_paragraph = Hash(elements.last)["type"] == "paragraph"

        elements.size > 0 && paragraphs_not_too_long && last_element_is_paragraph
      end
    end
    def prefix
      "<p class='font-semibold'>#{@conversation.context['title']}</p>".html_safe
    end
  end
end