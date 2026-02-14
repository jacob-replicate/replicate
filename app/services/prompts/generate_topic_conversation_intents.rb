module Prompts
  class GenerateTopicConversationIntents < Prompts::Base
    def validate(raw)
      json = Prompts::Base.extract_json(raw)
      intents = json["generation_intents"] || []
      failures = []

      failures << "not_array" unless intents.is_a?(Array)

      if intents.is_a?(Array)
        failures << "too_few_intents" if intents.length < 5
        failures << "too_many_intents" if intents.length > 7

        intents.each_with_index do |intent, idx|
          unless intent.is_a?(String) && !intent.strip.empty?
            failures << "intent_#{idx}_not_string"
            next
          end

          failures << "intent_#{idx}_too_short" if intent.length < 200
          failures << "intent_#{idx}_too_long" if intent.length > 600
        end
      end

      failures
    end
  end
end