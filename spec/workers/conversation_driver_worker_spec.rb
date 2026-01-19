require "rails_helper"

RSpec.describe ConversationDriverWorker, type: :worker do
  subject(:worker) { described_class.new }

  let(:generator_instance) { instance_double("MessageGenerators::Incident", deliver: true) }

  before do
    allow(MessageGenerators::Incident).to receive(:new).and_return(generator_instance)
  end

  describe "#perform" do
    it "drives the conversation" do
      convo = create(:conversation, variant: "incident")

      expect(MessageGenerators::Incident).to receive(:new).with(convo, nil).and_return(generator_instance)
      expect(generator_instance).to receive(:deliver)
      worker.perform(convo.id)
    end

    context "when latest author is :assistant" do
      it "returns early and does not drive the conversation" do
        conversation = create(:conversation, variant: "incident")

        allow_any_instance_of(Conversation).to receive(:latest_author).and_return(:assistant)
        expect(MessageGenerators::Incident).not_to receive(:new)
        worker.perform(conversation.id)
      end
    end
  end
end