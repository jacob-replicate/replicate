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
        "Create a conversation that explores resolver chain failures and cascading timeout behavior in production DNS infrastructure.",
        "Create a conversation that exposes TTL misconceptions and stale cache debugging scenarios."
      ]
    end

    let(:mock_conversation1) { build_stubbed(:conversation, name: "Resolver Chain Failures", code: "resolver-chain-failures") }
    let(:mock_conversation2) { build_stubbed(:conversation, name: "TTL Semantics", code: "ttl-semantics") }

    before do
      allow_any_instance_of(Prompts::GenerateTopicConversationIntents)
        .to receive(:call)
        .and_return({ "generation_intents" => mock_intents })
    end

    it "generates conversations for each intent" do
      generate_conversation_mock = instance_double(GenerateConversation)

      expect(GenerateConversation)
        .to receive(:new)
        .with(topic.id, mock_intents[0])
        .and_return(generate_conversation_mock)
      expect(generate_conversation_mock).to receive(:call).and_return(mock_conversation1)

      expect(GenerateConversation)
        .to receive(:new)
        .with(topic.id, mock_intents[1])
        .and_return(generate_conversation_mock)
      expect(generate_conversation_mock).to receive(:call).and_return(mock_conversation2)

      described_class.new(topic.id).call
    end

    it "continues generating conversations even if one fails" do
      generate_conversation_mock = instance_double(GenerateConversation)

      expect(GenerateConversation)
        .to receive(:new)
        .with(topic.id, mock_intents[0])
        .and_raise(StandardError.new("LLM failure"))

      expect(GenerateConversation)
        .to receive(:new)
        .with(topic.id, mock_intents[1])
        .and_return(generate_conversation_mock)
      expect(generate_conversation_mock).to receive(:call).and_return(mock_conversation2)

      described_class.new(topic.id).call
    end
  end
end