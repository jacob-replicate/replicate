require "rails_helper"

RSpec.describe MessageGenerators::Incident do
  let!(:conversation) { create(:conversation) }
  let!(:generator)    { described_class.new(conversation) }

  describe "#deliver_intro" do
    before do
      allow(generator).to receive(:broadcast_to_web)
      allow(generator).to receive(:deliver_multiple_choice_options)
      allow(CachedPrompt).to receive(:call).with(Prompts::IncidentIntro, generation_intent: conversation.generation_intent).and_return("intro text")
      allow(CachedPrompt).to receive(:call).with(Prompts::IncidentTitle, generation_intent: conversation.generation_intent).and_return("Test Title")
    end

    it "broadcasts to web and creates a message" do
      expect(generator).to receive(:broadcast_to_web).at_least(:once)
      generator.deliver_intro
      expect(conversation.messages.count).to eq(1)
    end
  end

  describe "#deliver_reply" do
    before do
      allow(generator).to receive(:broadcast_to_web)
      allow(generator).to receive(:deliver_multiple_choice_options)
      allow(generator).to receive(:deliver_article_suggestions)
      create(:message, conversation: conversation, user_generated: true, content: "test message")
    end

    it "broadcasts to web and creates a message" do
      allow(Prompts::IncidentReply).to receive_message_chain(:new, :call).and_return("reply text")

      expect(generator).to receive(:broadcast_to_web).at_least(:once)
      generator.deliver_reply
    end
  end
end