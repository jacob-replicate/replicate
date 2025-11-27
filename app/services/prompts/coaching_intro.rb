module Prompts
  class CoachingIntro < Prompts::Base
    def call
      parallel_batch_process do |elements|
        first_element = elements.first["content"].to_s

        failures = []
        failures << "not_array" if !elements.is_a?(Array)
        failures << "wrong_size" if elements.size != 2
        failures << "invalid_element_types" unless elements.all? { |element| Hash(element)["type"].present? }
        failures << "unexpected_types" unless elements.map { |e| e["type"] } == ["paragraph", "code"]
        failures << "first_element_too_long" if first_element.length > 300

        failures.each do |failure|
          Rails.logger.info("First element: #{first_element.first(10)}...")
          Rails.logger.warn(
            "Prompt validation failed for #{template_name}: - #{failure}"
          )
        end

        elements.is_a?(Array) &&
          elements.size == 2 &&
          elements.all? { |element| Hash(element)["type"].present? } &&
          elements.map { |e| e["type"] } == ["paragraph", "code"] &&
          elements.first["content"].to_s.length < 300
      end
    end

    def suffix
      "<p style='margin-top: 30px; font-size: 17px'><span class='font-semibold'>What's your first move here?</span></p>"
    end
  end
end