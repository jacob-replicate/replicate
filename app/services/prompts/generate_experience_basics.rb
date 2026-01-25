module Prompts
  class GenerateExperienceBasics < Prompts::Base
    def validate(raw)
      raw_json = Prompts::Base.extract_json(raw)
      failures = []

      failures << "raw_json_not_hash" unless raw_json.is_a?(Hash)
      failures << "missing_name" if raw_json["experience_name"].to_s.strip.empty?
      failures << "missing_description" if raw_json["experience_description"].to_s.strip.empty?
      failures << "missing_code" if raw_json["experience_code"].to_s.strip.empty?
      failures << "missing_refined_intent" if raw_json["refined_generation_intent"].to_s.strip.empty?

      code = raw_json["experience_code"].to_s.strip
      unless code.match?(/\A[a-z0-9]+(-[a-z0-9]+)*\z/)
        failures << "invalid_code_format"
      end
      failures << "code_too_long" if code.length > 25

      failures << "name_too_long" if raw_json["experience_name"].to_s.length > 100

      desc_length = raw_json["experience_description"].to_s.length
      failures << "description_too_short" if desc_length < 240
      failures << "description_too_long" if desc_length > 290

      intent_length = raw_json["refined_generation_intent"].to_s.length
      failures << "refined_intent_too_short" if intent_length < 400

      # Reject forbidden punctuation in user-facing text fields
      text_fields = ["experience_name", "experience_description"]
      text_fields.each do |field|
        value = raw_json[field].to_s
        failures << "#{field}_contains_em_dash" if value.include?("—")
        failures << "#{field}_contains_semicolon" if value.include?(";")
        failures << "#{field}_contains_double_quote" if value.include?('"')
        # Single quotes used for sectioning (not apostrophes in contractions)
        failures << "#{field}_contains_single_quote" if value.match?(/'[^']+'/)
      end

      failures
    end
  end
end