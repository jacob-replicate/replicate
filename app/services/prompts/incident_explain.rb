module Prompts
  class IncidentExplain < Prompts::Base
    def parse_response(raw)
      Prompts::RichText.format(Prompts::RichText.parse(raw))
    end

    def validate(raw)
      Prompts::RichText.validate(Prompts::RichText.parse(raw))
    end
  end
end