module Prompts
  class QuestionIntro < Prompts::Base
    def parse_response(raw)
      Prompts::RichText.format(Prompts::RichText.parse(raw))
    end

    def validate(raw)
      elements = Prompts::RichText.parse(raw)
      first_element = elements.first["content"].to_s rescue ""

      failures = []
      failures << "not_array" unless elements.is_a?(Array)
      failures << "too_few_elements" if elements.size < 1
      failures << "invalid_element_types" unless elements.all? { |element| Hash(element)["type"].present? }
      failures << "paragraphs_contain_backticks" if elements.any? { |e| e["type"] == "paragraph" && e["content"].to_s.include?("`") }
      failures << "first_element_too_long" if first_element.length > 400
      failures
    end
  end
end