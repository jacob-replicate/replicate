class PostmarkWebhooksController < ApplicationController
  def create
    return head :unauthorized unless valid_signature?

    conversation_id = params["InReplyTo"].downcase.gsub(/.*conversation-/, "").gsub(/@replicate\.info.*/, "")
    conversation = Conversation.find_by(id: conversation_id)
    webhook = PostmarkWebhook.create!(conversation: conversation, content: params.to_unsafe_h)
    ProcessPostmarkWebhookWorker.perform_async(webhook.id)

    head :ok
  end

  private

  def valid_signature?
    return true if Rails.env.development?

    secret    = ENV["POSTMARK_WEBHOOK_SECRET"]
    signature = request.headers["X-Postmark-Signature"]
    return false if secret.blank? || signature.blank?

    expected = Base64.strict_encode64(OpenSSL::HMAC.digest("sha256", secret, request.raw_post))
    ActiveSupport::SecurityUtils.secure_compare(expected, signature)
  end
end