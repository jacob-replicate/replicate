require "rails_helper"

RSpec.describe Conversation, type: :model do
  describe "associations" do
    it { should belong_to(:recipient).optional }
    it { should have_many(:messages).dependent(:destroy) }
  end

  describe "#email?" do
    it "returns true when channel is 'email'" do
      conversation = build(:conversation, channel: "email")
      expect(conversation.email?).to be(true)
    end

    it "returns false otherwise" do
      conversation = build(:conversation, channel: "web")
      expect(conversation.email?).to be(false)
    end
  end

  describe "#web?" do
    it "returns true when channel is 'web'" do
      conversation = build(:conversation, channel: "web")
      expect(conversation.web?).to be(true)
    end

    it "returns false otherwise" do
      conversation = build(:conversation, channel: "email")
      expect(conversation.web?).to be(false)
    end
  end

  describe "#latest_user_message" do
    it "returns empty string when there are no user messages" do
      conversation = create(:conversation)
      create(:message, conversation:, user_generated: false, content: "system a", created_at: 1.hour.ago)
      create(:message, conversation:, user_generated: false, content: "system b", created_at: 10.minutes.ago)

      expect(conversation.latest_user_message).to eq("")
    end

    it "returns the content of the most recent user message" do
      conversation = create(:conversation)
      create(:message, conversation:, user_generated: true, content: "older user", created_at: 2.hours.ago)
      create(:message, conversation:, user_generated: true, content: "newer user", created_at: 5.minutes.ago)

      expect(conversation.latest_user_message).to eq("newer user")
    end
  end

  describe "#latest_system_message" do
    it "returns empty string when there are no system messages" do
      conversation = create(:conversation)
      create(:message, conversation:, user_generated: true, content: "user a", created_at: 30.minutes.ago)

      expect(conversation.latest_system_message).to eq("")
    end

    it "returns the content of the most recent system message" do
      conversation = create(:conversation)
      create(:message, conversation:, user_generated: false, content: "older sys", created_at: 1.hour.ago)
      create(:message, conversation:, user_generated: false, content: "newer sys", created_at: 2.minutes.ago)

      expect(conversation.latest_system_message).to eq("newer sys")
    end
  end

  describe "#latest_author" do
    it "returns nil when there are no messages" do
      conversation = create(:conversation)
      expect(conversation.latest_author).to be_nil
    end

    it "returns :user when the latest message is user-generated" do
      conversation = create(:conversation)
      create(:message, conversation:, user_generated: false, created_at: 1.hour.ago)
      create(:message, conversation:, user_generated: true, created_at: 1.minute.ago)

      expect(conversation.latest_author).to eq(:user)
    end

    it "returns :assistant when the latest message is system-generated" do
      conversation = create(:conversation)
      create(:message, conversation:, user_generated: true, created_at: 1.hour.ago)
      create(:message, conversation:, user_generated: false, created_at: 1.minute.ago)

      expect(conversation.latest_author).to eq(:assistant)
    end

    it "uses created_at ordering (not id ordering)" do
      conversation = create(:conversation)
      # Same creation sequence, but crafted timestamps ensure ordering by created_at
      first  = create(:message, conversation:, user_generated: true,  created_at: 10.minutes.ago)
      second = create(:message, conversation:, user_generated: false, created_at: 2.minutes.ago)
      third  = create(:message, conversation:, user_generated: true,  created_at: 5.minutes.ago)

      expect(conversation.latest_author).to eq(:assistant) # `second` is latest by created_at
      expect([first, second, third].sort_by(&:created_at).last).to eq(second)
    end
  end

  describe "#message_history" do
    it "returns messages ordered ascending by created_at with proper roles" do
      conversation = create(:conversation)

      m1 = create(:message, conversation:, user_generated: false, content: "sys one",  created_at: 3.minutes.ago)
      m3 = create(:message, conversation:, user_generated: false, content: "sys three", created_at: 1.minute.ago)
      m2 = create(:message, conversation:, user_generated: true,  content: "user two", created_at: 2.minutes.ago)

      allow(SanitizeAiContent).to receive(:call) { |content| "SANITIZED: #{content}" }

      history = conversation.message_history

      expect(history).to eq([
        { role: "assistant", content: "SANITIZED: #{m1.content}" },
        { role: "user",      content: "SANITIZED: #{m2.content}" },
        { role: "assistant", content: "SANITIZED: #{m3.content}" }
      ])

      expect(SanitizeAiContent).to have_received(:call).with("sys one").once
      expect(SanitizeAiContent).to have_received(:call).with("user two").once
      expect(SanitizeAiContent).to have_received(:call).with("sys three").once
    end
  end

  describe "#next_message_sequence" do
    let(:conversation) { create(:conversation) }

    context "when there are no messages" do
      it "returns 0" do
        expect(conversation.next_message_sequence).to eq(0)
      end
    end

    context "with a mix of user/system messages and no fake names" do
      it "computes sequence from real user/system counts" do
        create_list(:message, 3, conversation:, user_generated: true)
        create_list(:message, 2, conversation:, user_generated: false)
        expect(conversation.next_message_sequence).to eq(14)
      end
    end

    context "with messages containing fake names (treated as system for weighting)" do
      it "reclassifies fake-name messages and applies correct weighting" do
        create(:message, conversation:, user_generated: true,  content: "Hello from a normal user")
        create(:message, conversation:, user_generated: true,  content: "Ping Taylor Morales about this") # fake name
        create(:message, conversation:, user_generated: false, content: "I am a system note")
        expect(conversation.next_message_sequence).to eq(10)
      end

      it "counts multiple fake-name hits across any roles" do
        create(:message, conversation:, user_generated: true,  content: "Regular user content")
        create(:message, conversation:, user_generated: true,  content: "Casey Patel asked for logs")
        create(:message, conversation:, user_generated: false, content: "Alex Shaw escalated this issue")
        create(:message, conversation:, user_generated: false, content: "Plain system message")
        expect(conversation.next_message_sequence).to eq(16)
      end
    end
  end
end