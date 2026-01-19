# spec/channels/conversation_channel_spec.rb
require "rails_helper"

RSpec.describe ConversationChannel, type: :channel do
  let(:conversation) { create(:conversation) }

  before do
    stub_connection
  end

  describe "#subscribed" do
    it "streams for the conversation" do
      subscribe(id: conversation.id)
      expect(subscription).to be_confirmed
      expect(subscription).to have_stream_for(conversation)
    end

    context "when conversation has no messages" do
      it "enqueues ConversationDriverWorker" do
        allow(ConversationDriverWorker).to receive(:perform_async)

        subscribe(id: conversation.id)

        expect(ConversationDriverWorker).to have_received(:perform_async).with(conversation.id)
      end
    end

    context "when conversation already has messages" do
      before do
        create(:message, conversation:, user_generated: true, content: "existing")
      end

      it "does not create a new message and does not enqueue worker" do
        expect(ConversationDriverWorker).not_to receive(:perform_async)

        expect {
          subscribe(id: conversation.id)
        }.not_to change { conversation.messages.count }
      end
    end

    context "when conversation id is invalid" do
      it "rejects the subscription" do
        subscribe(id: -999)
        expect(subscription).to be_rejected
      end
    end
  end
end