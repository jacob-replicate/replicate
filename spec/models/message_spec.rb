require "rails_helper"

RSpec.describe Message, type: :model do
  describe "associations" do
    it { should belong_to(:conversation) }
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
  end

  describe "#plain_text_content" do
    it "strips HTML tags and returns plain text" do
      message = create(:message, content: "<p>Hello <b>world</b></p>")
      expect(message.plain_text_content).to eq("Hello world")
    end

    it "removes the literal unsubscribe marker '- Unsubscribe'" do
      message = create(:message, content: "Some text - Unsubscribe")
      expect(message.plain_text_content).to eq("Some text")
    end

    it "returns an empty string if content is only the unsubscribe marker" do
      message = create(:message, content: "- Unsubscribe")
      expect(message.plain_text_content).to eq("")
    end
  end

  describe "after_create :generate_email_message_id_header" do
    let(:email_conversation) { create(:conversation, channel: "email") }
    let(:web_conversation)   { create(:conversation, channel: "web") }

    it "sets email_message_id_header for system messages in email conversations" do
      msg = create(:message, conversation: email_conversation, user_generated: false, content: "system hello")
      expect(msg.reload.email_message_id_header).to eq("<message-#{msg.id}@mail.replicate.info>")
    end

    it "does NOT set email_message_id_header for user-generated messages (even in email conversations)" do
      msg = create(:message, conversation: email_conversation, user_generated: true, content: "user hello")
      expect(msg.reload.email_message_id_header).to be_nil
    end

    it "does NOT set email_message_id_header for system messages in non-email conversations" do
      msg = create(:message, conversation: web_conversation, user_generated: false, content: "system on web")
      expect(msg.reload.email_message_id_header).to be_nil
    end

    it "wraps the id in angle brackets and uses the message id" do
      msg = create(:message, conversation: email_conversation, user_generated: false, content: "check format")
      header = msg.reload.email_message_id_header

      expect(header).to start_with("<")
      expect(header).to end_with(">")
      expect(header).to include("message-#{msg.id}@mail.replicate.info")
    end
  end
end