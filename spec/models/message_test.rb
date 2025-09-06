require "rails_helper"

RSpec.describe Message, type: :model do
  describe "associations" do
    it { should belong_to(:conversation) }
    it { should belong_to(:user).optional }
  end

  describe "validations" do
    it { should validate_presence_of(:content) }
  end

  describe "scopes" do
    it ".system returns only non-user-generated messages" do
      conversation = create(:conversation)
      system_message = create(:message, conversation:, user_generated: false)
      user_message   = create(:message, conversation:, user_generated: true)
      expect(described_class.system).to contain_exactly(system_message)
      expect(described_class.system).not_to include(user_message)
    end

    it ".user returns only user-generated messages" do
      conversation = create(:conversation)
      system_message = create(:message, conversation:, user_generated: false)
      user_message   = create(:message, conversation:, user_generated: true)
      expect(described_class.user).to contain_exactly(user_message)
      expect(described_class.user).not_to include(system_message)
    end
  end

  describe "callbacks" do
    let(:conversation) { create(:conversation, channel: "web", context: {}) }

    before do
      allow(ConversationChannel).to receive(:broadcast_to)
      allow(ConversationDriverWorker).to receive(:perform_async)
    end

    context "user-generated in a web conversation" do
      it "broadcasts the message and a done event with the correct sequences and enqueues a system reply" do
        allow(conversation).to receive(:next_message_sequence).and_return(10)

        message = create(:message, conversation:, user_generated: true, content: "Hello")

        expect(ConversationChannel).to have_received(:broadcast_to).with(
          conversation,
          hash_including(message: "Hello", user_generated: true, sequence: 8)
        ).once

        expect(ConversationChannel).to have_received(:broadcast_to).with(
          conversation,
          hash_including(type: "done", sequence: 9)
        ).once

        expect(ConversationDriverWorker).to have_received(:perform_async).with(message.conversation_id).once
      end
    end

    context "user-generated in a non-web conversation" do
      let(:email_conversation) { create(:conversation, channel: "email", context: {}) }

      it "does not broadcast to the channel but still enqueues a system reply" do
        create(:message, conversation: email_conversation, user_generated: true, content: "Hello")

        expect(ConversationChannel).not_to have_received(:broadcast_to)
        expect(ConversationDriverWorker).to have_received(:perform_async).with(email_conversation.id).once
      end
    end

    context "system message (not user_generated)" do
      it "does not broadcast and does not enqueue a system reply" do
        create(:message, conversation:, user_generated: false, content: "system says hi")

        expect(ConversationChannel).not_to have_received(:broadcast_to)
        expect(ConversationDriverWorker).not_to have_received(:perform_async)
      end
    end

    context "demo message (conversation_type: landing_demo)" do
      let(:demo_conversation) { create(:conversation, channel: "web", context: { "conversation_type" => "landing_demo" }) }

      it "does not broadcast and does not enqueue a system reply even if user_generated" do
        create(:message, conversation: demo_conversation, user_generated: true, content: "demo hello")

        expect(ConversationChannel).not_to have_received(:broadcast_to)
        expect(ConversationDriverWorker).not_to have_received(:perform_async)
      end
    end
  end
end