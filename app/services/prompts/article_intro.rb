module Prompts
  class ArticleIntro < Prompts::Base
    def parse_response(raw)
      elements = Prompts::RichText.parse(raw)
      Prompts::RichText.format(elements, prefix: prefix)
    end

    def validate(raw)
      elements = Prompts::RichText.parse(raw)
      paragraphs = elements.select { |e| Hash(e).with_indifferent_access[:type] == "paragraph" }.map { |e| e.with_indifferent_access[:content].to_s }
      last_element_type = Hash(elements.last).with_indifferent_access["type"]

      failures = []
      failures << "no_elements" if elements.size.zero?
      failures << "paragraphs_contain_asterisks" if paragraphs.any? { |p| p.include?("*") }
      failures << "paragraphs_contain_backticks" if paragraphs.any? { |p| p.include?("`") }
      failures << "last_element_not_paragraph" unless last_element_type == "paragraph"
      failures
    end

    def prefix
      "<p class='font-semibold'>#{@context['title']}</p>".html_safe
    end
  end
end