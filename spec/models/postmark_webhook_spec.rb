require "rails_helper"

RSpec.describe PostmarkWebhook, type: :model do
  let(:payload) do
    {
      "FromName" => "Postmarkapp Support",
      "MessageStream" => "inbound",
      "From" => "support@postmarkapp.com",
      "To" => "\"Firstname Lastname\" <yourhash+SampleHash@inbound.postmarkapp.com>",
      "Subject" => "Test subject",
      "MessageID" => "73e6d360-66eb-11e1-8e72-a8904824019b",
      "StrippedTextReply" => "This is a test text body.",
      "Headers" => [
        { "Name" => "Message-ID", "Value" => "<CAF12345abc@mail.gmail.com>" },
        { "Name" => "X-Spam-Status", "Value" => "No" }
      ]
    }
  end

  let(:webhook) { build(:postmark_webhook, content: payload) }

  describe "associations" do
    it { should belong_to(:conversation).optional }
  end

  describe "#message" do
    it "returns the TextBody from content" do
      expect(webhook.message).to eq("This is a test text body.")
    end

    it "returns nil when TextBody is missing" do
      w = build(:postmark_webhook, content: {})
      expect(w.message).to be_nil
    end
  end

  describe "#postmark_message_id" do
    it "returns Postmark's internal MessageID field" do
      expect(webhook.postmark_message_id).to eq("73e6d360-66eb-11e1-8e72-a8904824019b")
    end

    it "returns nil when MessageID is missing" do
      w = build(:postmark_webhook, content: {})
      expect(w.postmark_message_id).to be_nil
    end
  end

  describe "#rfc_message_id" do
    it "extracts the RFC Message-ID from the Headers array" do
      expect(webhook.rfc_message_id).to eq("<CAF12345abc@mail.gmail.com>")
    end

    it "is case-insensitive on header name" do
      w = build(:postmark_webhook, content: payload.merge(
        "Headers" => [{ "Name" => "message-id", "Value" => "<lowercase@example.com>" }]
      ))
      expect(w.rfc_message_id).to eq("<lowercase@example.com>")
    end

    it "returns nil when Headers is missing" do
      w = build(:postmark_webhook, content: payload.except("Headers"))
      expect(w.rfc_message_id).to be_nil
    end

    it "returns nil when Message-ID header is not present" do
      w = build(:postmark_webhook, content: payload.merge("Headers" => [{ "Name" => "X-Only", "Value" => "v" }]))
      expect(w.rfc_message_id).to be_nil
    end
  end

  describe "#in_reply_to_message" do
    let!(:conversation) { create(:conversation) }

    it "finds the message via In-Reply-To header when present" do
      parent = create(:message, conversation:, content: "parent", email_message_id_header: "<parent@mail.invariant.training>")

      w = build(:postmark_webhook, content: payload.merge(
        "Headers" => [
          { "Name" => "In-Reply-To", "Value" => "<parent@mail.invariant.training>" },
          { "Name" => "Message-ID",  "Value" => "<child@mail.invariant.training>" }
        ]
      ))

      expect(w.in_reply_to_message).to eq(parent)
    end

    it "falls back to References when In-Reply-To is absent/blank" do
      # Only one of the references actually exists to keep selection deterministic
      referenced = create(:message, conversation:, content: "in chain", email_message_id_header: "<exists@mail.invariant.training>")

      w = build(:postmark_webhook, content: payload.merge(
        "Headers" => [
          { "Name" => "References", "Value" => "<nope@mail.invariant.training> <exists@mail.invariant.training> <alsonope@mail.invariant.training>" },
          { "Name" => "Message-ID", "Value" => "<child@mail.invariant.training>" }
        ]
      ))

      expect(w.in_reply_to_message).to eq(referenced)
    end

    it "returns nil when neither In-Reply-To nor References is present" do
      w = build(:postmark_webhook, content: payload.merge("Headers" => []))
      expect(w.in_reply_to_message).to be_nil
    end

    it "returns nil when headers are present but empty/blank" do
      w = build(:postmark_webhook, content: payload.merge(
        "Headers" => [
          { "Name" => "In-Reply-To", "Value" => "" },
          { "Name" => "References",  "Value" => "" }
        ]
      ))
      expect(w.in_reply_to_message).to be_nil
    end

    it "returns nil when no matching Message exists for the referenced IDs" do
      w = build(:postmark_webhook, content: payload.merge(
        "Headers" => [
          { "Name" => "In-Reply-To", "Value" => "<unknown@mail.invariant.training>" }
        ]
      ))
      expect(w.in_reply_to_message).to be_nil
    end
  end
end