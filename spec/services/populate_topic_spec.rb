require "rails_helper"

RSpec.describe PopulateTopic do
  let(:topic) { create(:topic, name: "DNS", description: "DNS resolution and caching behavior") }

  describe "#initialize" do
    it "finds the topic by ID" do
      service = described_class.new(topic.id)
      expect(service.instance_variable_get(:@topic)).to eq(topic)
    end

    it "raises ActiveRecord::RecordNotFound for invalid ID" do
      expect { described_class.new(-1) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "#call" do
    let(:mock_intents) do
      [
        "Create an experience that explores resolver chain failures and cascading timeout behavior in production DNS infrastructure.",
        "Create an experience that exposes TTL misconceptions and stale cache debugging scenarios."
      ]
    end

    let(:mock_experience1) { build_stubbed(:experience, name: "Resolver Chain Failures", code: "resolver-chain-failures") }
    let(:mock_experience2) { build_stubbed(:experience, name: "TTL Semantics", code: "ttl-semantics") }

    before do
      allow_any_instance_of(Prompts::GenerateTopicExperienceIntents)
        .to receive(:call)
        .and_return({ "generation_intents" => mock_intents })
    end

    it "generates experiences for each intent" do
      generate_experience_mock = instance_double(GenerateExperience)

      expect(GenerateExperience)
        .to receive(:new)
        .with(topic.id, mock_intents[0])
        .and_return(generate_experience_mock)
      expect(generate_experience_mock).to receive(:call).and_return(mock_experience1)

      expect(GenerateExperience)
        .to receive(:new)
        .with(topic.id, mock_intents[1])
        .and_return(generate_experience_mock)
      expect(generate_experience_mock).to receive(:call).and_return(mock_experience2)

      described_class.new(topic.id).call
    end

    it "continues generating experiences even if one fails" do
      generate_experience_mock = instance_double(GenerateExperience)

      expect(GenerateExperience)
        .to receive(:new)
        .with(topic.id, mock_intents[0])
        .and_raise(StandardError.new("LLM failure"))

      expect(GenerateExperience)
        .to receive(:new)
        .with(topic.id, mock_intents[1])
        .and_return(generate_experience_mock)
      expect(generate_experience_mock).to receive(:call).and_return(mock_experience2)

      described_class.new(topic.id).call
    end
  end
end