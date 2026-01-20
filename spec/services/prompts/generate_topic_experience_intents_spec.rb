require "rails_helper"

RSpec.describe Prompts::GenerateTopicExperienceIntents do
  let(:context) do
    {
      topic_name: "DNS",
      topic_description: "DNS resolution and caching behavior"
    }
  end

  subject(:prompt) { described_class.new(context: context) }

  describe "#validate" do
    def valid_intent
      "Create an experience that teaches engineers how this system fails in production and how to debug cascading failures. Focus on timeout behavior, cache invalidation timing, and error handling edge cases. Include scenarios where stale data causes outages."
    end

    def raw_json(intents)
      { "generation_intents" => intents }.to_json
    end

    context "with valid response" do
      it "passes validation" do
        failures = prompt.validate(raw_json(Array.new(6) { valid_intent }))
        expect(failures).to be_empty
      end
    end

    context "with invalid response" do
      it "fails when generation_intents is missing" do
        failures = prompt.validate("{}")
        expect(failures).to include("too_few_intents")
      end

      it "fails when there are too few intents" do
        failures = prompt.validate(raw_json(["Create an experience..."]))
        expect(failures).to include("too_few_intents")
      end

      it "fails when intent is not a string" do
        failures = prompt.validate(raw_json(Array.new(6) { |i| i == 0 ? nil : valid_intent }))
        expect(failures).to include("intent_0_not_string")
      end

      it "fails when generation_intent is too short" do
        failures = prompt.validate(raw_json(Array.new(6) { "Create an experience about DNS." }))
        expect(failures).to include("intent_0_too_short")
      end
    end
  end
end