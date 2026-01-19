module Prompts
  class IncidentTitle < Prompts::Base
    def parse_response(raw)
      raw
    end

    def validate(raw)
      raw.present? ? [] : ["empty"]
    end
  end
end