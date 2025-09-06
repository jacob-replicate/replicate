# spec/requests/postmark_webhooks_spec.rb
require "rails_helper"
require "sidekiq/testing"

RSpec.describe "Postmark Webhooks", type: :request do
  let(:path) { "/webhooks/postmark" }
  let(:valid_ip) { "3.134.147.250" }
  let(:invalid_ip) { "127.0.0.1" }

  let(:payload) do
    {
      "FromName" => "Postmarkapp Support",
      "MessageStream" => "inbound",
      "From" => "support@postmarkapp.com",
      "FromFull" => {
        "Email" => "support@postmarkapp.com",
        "Name" => "Postmarkapp Support",
        "MailboxHash" => ""
      },
      "To" => "\"Firstname Lastname\" <yourhash+SampleHash@inbound.postmarkapp.com>",
      "ToFull" => [
        {
          "Email" => "yourhash+SampleHash@inbound.postmarkapp.com",
          "Name" => "Firstname Lastname",
          "MailboxHash" => "SampleHash"
        }
      ],
      "Cc" => "\"First Cc\" <firstcc@postmarkapp.com>, secondCc@postmarkapp.com>",
      "CcFull" => [
        { "Email" => "firstcc@postmarkapp.com", "Name" => "First Cc", "MailboxHash" => "" },
        { "Email" => "secondcc@postmarkapp.com", "Name" => "", "MailboxHash" => "" }
      ],
      "Bcc" => "\"First Bcc\" <firstbcc@postmarkapp.com>, secondbcc@postmarkapp.com>",
      "BccFull" => [
        { "Email" => "firstbcc@postmarkapp.com", "Name" => "First Bcc", "MailboxHash" => "" },
        { "Email" => "secondbcc@postmarkapp.com", "Name" => "", "MailboxHash" => "" }
      ],
      "OriginalRecipient" => "yourhash+SampleHash@inbound.postmarkapp.com",
      "Subject" => "Test subject",
      "MessageID" => "73e6d360-66eb-11e1-8e72-a8904824019b",
      "ReplyTo" => "replyto@postmarkapp.com",
      "MailboxHash" => "SampleHash",
      "Date" => "Fri, 1 Aug 2014 16:45:32 -04:00",
      "TextBody" => "This is a test text body.",
      "HtmlBody" => "<html><body><p>This is a test html body.</p></body></html>",
      "StrippedTextReply" => "This is the reply text",
      "Tag" => "TestTag",
      "Headers" => [
        { "Name" => "Message-ID", "Value" => "<CAF12345abc@mail.gmail.com>" },
        { "Name" => "X-Header-Test", "Value" => "" },
        { "Name" => "X-Spam-Status", "Value" => "No" },
        { "Name" => "X-Spam-Score", "Value" => "-0.1" },
        { "Name" => "X-Spam-Tests", "Value" => "DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,SPF_PASS" }
      ],
      "Attachments" => [
        {
          "Name" => "test.txt",
          "Content" => "VGhpcyBpcyBhdHRhY2htZW50IGNvbnRlbnRzLCBiYXNlLTY0IGVuY29kZWQu",
          "ContentType" => "text/plain",
          "ContentLength" => "45"
        }
      ]
    }
  end

  def post_with_ip(ip, body = payload)
    post path, params: body, headers: { "REMOTE_ADDR" => ip, "X-Forwarded-For" => ip }
  end

  around do |example|
    Sidekiq::Testing.inline! { example.run }
  end

  describe "POST /webhooks/postmark" do
    context "invalid IP" do
      it "returns 401 and does not create a PostmarkWebhook" do
        expect { post_with_ip(invalid_ip) }.not_to change { PostmarkWebhook.count }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "valid IP" do
      it "returns 200, persists payload verbatim, runs processor inline, and sets processed_at" do
        expect {
          post_with_ip(valid_ip)
        }.to change { PostmarkWebhook.count }.by(1)

        expect(response).to have_http_status(:ok)

        webhook = PostmarkWebhook.last
        expect(webhook.content).to eq(payload)
        expect(webhook.processed_at).to be_present
      end
    end
  end
end