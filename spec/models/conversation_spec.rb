require "rails_helper"

RSpec.describe Conversation, type: :model do
  describe "associations" do
    it { should belong_to(:recipient).optional }
    it { should have_many(:messages).dependent(:destroy) }
  end


  describe "#latest_user_message" do
    it "returns empty string when there are no user messages" do
      conversation = create(:conversation)
      create(:message, conversation:, user_generated: false, content: "system a", created_at: 1.hour.ago)
      create(:message, conversation:, user_generated: false, content: "system b", created_at: 10.minutes.ago)

      expect(conversation.latest_user_message).to eq(nil)
    end

    it "returns the content of the most recent user message" do
      conversation = create(:conversation)
      create(:message, conversation:, user_generated: true, content: "older user", created_at: 2.hours.ago)
      newer_message = create(:message, conversation:, user_generated: true, content: "newer user", created_at: 5.minutes.ago)

      expect(conversation.latest_user_message).to eq(newer_message)
    end
  end

  describe "#latest_system_message" do
    it "returns empty string when there are no system messages" do
      conversation = create(:conversation)
      create(:message, conversation:, user_generated: true, content: "user a", created_at: 30.minutes.ago)

      expect(conversation.latest_system_message).to eq(nil)
    end

    it "returns the content of the most recent system message" do
      conversation = create(:conversation)
      create(:message, conversation:, user_generated: false, content: "older sys", created_at: 1.hour.ago)
      newer_message = create(:message, conversation:, user_generated: false, content: "newer sys", created_at: 2.minutes.ago)

      expect(conversation.latest_system_message).to eq(newer_message)
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
    let(:conversation) { create(:conversation, sequence_count: 0) }

    context "when sequence_count is 0" do
      it "returns 1" do
        expect(conversation.next_message_sequence).to eq(1)
      end
    end

    context "when sequence_count has a value" do
      it "returns sequence_count + 1" do
        conversation.update!(sequence_count: 5)
        expect(conversation.next_message_sequence).to eq(6)
      end
    end

    context "with multiple increments" do
      it "tracks sequence correctly" do
        conversation.update!(sequence_count: 10)
        expect(conversation.next_message_sequence).to eq(11)

        conversation.update!(sequence_count: 15)
        expect(conversation.next_message_sequence).to eq(16)
      end
    end
  end
end