require "rails_helper"
require "sidekiq/testing"

RSpec.describe "Postmark webhooks", type: :request do
  Sidekiq::Testing.fake!

  let(:secret) { "super-secret" }
  let(:headers) { { "CONTENT_TYPE" => "application/json" } }

  # Helper to compute the same signature your controller expects
  def signature_for(body, key = secret)
    Base64.strict_encode64(
      OpenSSL::HMAC.digest("sha256", key, body)
    )
  end

  before do
    # Easiest, least invasive way to set the env var just for this spec
    stub_const("ENV", ENV.to_hash.merge("POSTMARK_WEBHOOK_SECRET" => secret))
  end

  describe "POST /postmark_webhooks" do
    let!(:conversation) { create(:conversation) } # UUID id
    let(:payload_hash) do
      {
        "InReplyTo" => "conversation-#{conversation.id}@replicate.info",
        "From"      => "support@postmarkapp.com",
        "Subject"   => "Test subject",
        # …include as much as you want; controller saves params wholesale
        "TextBody"  => "This is a test text body."
      }
    end
    let(:body)     { payload_hash.to_json }
    let(:authz)    { { "X-Postmark-Signature" => signature_for(body) } }

    xit "creates a PostmarkWebhook, associates conversation, enqueues worker, and returns 200" do
      expect {
        post "/postmark_webhooks",
          params: body,
          headers: headers.merge(authz)
      }
        .to change(PostmarkWebhook, :count).by(1)
                                           .and change { ProcessPostmarkWebhookWorker.jobs.size }.by(1)

      expect(response).to have_http_status(:ok)

      webhook = PostmarkWebhook.last
      expect(webhook.conversation_id).to eq(conversation.id)
      expect(webhook.webhook_type).to eq("inbound") # if you set a default; remove if not
      # controller does `params.to_unsafe_h` so JSON keys should be there verbatim
      expect(webhook.content).to include(payload_hash)
    end

    xit "returns 401 and does nothing when signature is missing" do
      expect {
        post "/postmark_webhooks",
          params: body,
          headers: headers # no signature
      }
        .to not_change(PostmarkWebhook, :count)
          .and not_change { ProcessPostmarkWebhookWorker.jobs.size }

      expect(response).to have_http_status(:unauthorized)
    end

    xit "returns 401 and does nothing when signature is invalid" do
      bad_authz = { "X-Postmark-Signature" => signature_for(body, "wrong-key") }

      expect {
        post "/postmark_webhooks",
          params: body,
          headers: headers.merge(bad_authz)
      }
        .to not_change(PostmarkWebhook, :count)
          .and not_change { ProcessPostmarkWebhookWorker.jobs.size }

      expect(response).to have_http_status(:unauthorized)
    end

    xit "still creates a webhook when the conversation id doesn't exist (conversation=nil)" do
      unknown_id = SecureRandom.uuid
      body2 = payload_hash.merge("InReplyTo" => "Re: something conversation-#{unknown_id}@replicate.info").to_json

      expect {
        post "/postmark_webhooks",
          params: body2,
          headers: headers.merge("X-Postmark-Signature" => signature_for(body2))
      }.to change(PostmarkWebhook, :count).by(1)

      expect(PostmarkWebhook.last.conversation).to be_nil
      expect(response).to have_http_status(:ok)
    end
  end
end