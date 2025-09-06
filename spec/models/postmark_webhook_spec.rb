# frozen_string_literal: true
require "rails_helper"

RSpec.describe PostmarkWebhook, type: :model do
  describe "associations" do
    it { should belong_to(:conversation).optional }
  end

  describe "#message" do
    it "returns the TextBody from content" do
      webhook = build(:postmark_webhook, content: { "TextBody" => "Hello world" })
      expect(webhook.message).to eq("Hello world")
    end

    it "returns nil when TextBody is missing" do
      webhook = build(:postmark_webhook, content: { "OtherKey" => "nope" })
      expect(webhook.message).to be_nil
    end
  end

  describe "#message_id" do
    it "returns the MessageID from content" do
      webhook = build(:postmark_webhook, content: { "MessageID" => "abc-123" })
      expect(webhook.message_id).to eq("abc-123")
    end

    it "returns nil when MessageID is missing" do
      webhook = build(:postmark_webhook, content: {})
      expect(webhook.message_id).to be_nil
    end
  end
end