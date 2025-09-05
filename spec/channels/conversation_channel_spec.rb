# spec/channels/conversation_channel_spec.rb
require "rails_helper"

RSpec.describe ConversationChannel, type: :channel do
  let(:conversation) { create(:conversation, channel: channel_type, context: context) }
  let(:context) { {} }

  before do
    stub_connection
  end

  describe "#subscribed" do
    context "when conversation is web" do
      let(:channel_type) { "web" }

      it "streams for the conversation" do
        subscribe(id: conversation.id)
        expect(subscription).to be_confirmed
        expect(subscription).to have_stream_for(conversation)
      end

      context "when conversation has no messages and context includes initial_message" do
        let(:context) { { "initial_message" => "hello world" } }

        it "creates the initial message" do
          expect {
            subscribe(id: conversation.id)
          }.to change { conversation.messages.user.count }.by(1)

          expect(conversation.messages.last.content).to eq("hello world")
        end
      end

      context "when conversation has no messages and no initial_message in context" do
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
    end

    context "when conversation is not web" do
      let(:channel_type) { "email" }

      it "rejects the subscription" do
        subscribe(id: conversation.id)
        expect(subscription).to be_rejected
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