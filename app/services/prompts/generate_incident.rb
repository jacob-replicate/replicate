module Prompts
  class GenerateIncident < Prompts::Base
    def validate(raw)
      raw_json = Prompts::Base.extract_json(raw)
      failures = []

      failures << "raw_json_not_hash" unless raw_json.is_a?(Hash)
      failures << "missing_incident" unless raw_json["incident"].is_a?(Hash)

      if raw_json["incident"].is_a?(Hash)
        incident = raw_json["incident"]

        unless incident["title"].is_a?(String) && !incident["title"].strip.empty?
          failures << "incident_missing_title"
        end

        if incident["title"].is_a?(String) && incident["title"].length > 70
          failures << "incident_title_too_long"
        end

        unless incident["body"].is_a?(String) && !incident["body"].strip.empty?
          failures << "incident_missing_body"
        end

        if incident["body"].is_a?(String)
          failures << "incident_body_too_short" if incident["body"].length < 100
          failures << "incident_body_too_long" if incident["body"].length > 215
        end


        unless incident["generation_intent"].is_a?(String) && !incident["generation_intent"].strip.empty?
          failures << "incident_missing_generation_intent"
        end
      end

      failures
    end

    def template_name
      "generate_incident"
    end
  end
end