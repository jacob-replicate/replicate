module Prompts
  class IncidentIntro < Prompts::Base
    SUFFIX = "<p style='margin-top: 25px; font-size: 16px'><span class='font-medium'>What's your first move here?</span></p>"

    def parse_response(raw)
      elements = Prompts::RichText.parse(raw)
      Prompts::RichText.format(elements, suffix: SUFFIX)
    end

    def validate(raw)
      elements = Prompts::RichText.parse(raw)
      first_element = elements.first["content"].to_s rescue ""

      failures = []
      failures << "not_array" unless elements.is_a?(Array)
      failures << "wrong_size" if elements.size != 2
      failures << "invalid_element_types" unless elements.all? { |element| Hash(element)["type"].present? }
      failures << "paragraphs_contain_backticks" if elements.any? { |e| e["type"] == "paragraph" && e["content"].to_s.include?("`") }
      failures << "unexpected_types" unless elements.map { |e| e["type"] } == ["paragraph", "code"]
      failures << "first_element_too_long" if first_element.length > 300
      failures
    end
  end
end