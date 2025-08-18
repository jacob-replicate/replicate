class PostmarkWebhooksController < ApplicationController
  def create
    return head :ok unless inbound_record?
    return head :unauthorized unless valid_signature?
    return head :bad_request unless required_fields_present?

    conversation = find_conversation_from_header
    return head :not_found unless conversation
    return head :forbidden unless sender_matches?(conversation)
    return head :too_many_requests if rate_limited?(conversation.id)
    return head :bad_request if message_content.blank?
    return head :ok if duplicate_message?(conversation)

    message = conversation.messages.create(
      content: message_content,
      user_generated: true
    )

    return head :unprocessable_entity unless message.persisted?

    ConversationDriverWorker.perform_async(message.id)
    head :ok
  end

  private

  def inbound_record?
    params["RecordType"] == "Inbound"
  end

  def valid_signature?
    return true if Rails.env.development?

    secret    = ENV["POSTMARK_WEBHOOK_SECRET"]
    signature = request.headers["X-Postmark-Signature"]
    return false if secret.blank? || signature.blank?

    expected = Base64.strict_encode64(OpenSSL::HMAC.digest("sha256", secret, request.raw_post))
    ActiveSupport::SecurityUtils.secure_compare(expected, signature)
  end

  def required_fields_present?
    message_id.present? && in_reply_to.present? && raw_content.present?
  end

  def find_conversation_from_header
    return nil unless in_reply_to.is_a?(String)

    id = in_reply_to.downcase.gsub(/.*conversation-/, "").gsub(/@replicate\.info.*/, "")
    Conversation.find_by(id: id)
  end

  def sender_matches?(conversation)
    sender = params.dig("FromFull", "Email") || params["From"]
    return false if sender.blank?

    sender.downcase.strip == conversation.recipient.email.downcase.strip
  end

  def rate_limited?(conversation_id)
    key = "postmark/conversation:#{conversation_id}/rate"
    limit = 10
    window = 1.minute

    Rails.cache.increment(key, 1, expires_in: window) > limit
  end

  def duplicate_message?(conversation)
    conversation.messages.exists?(content: message_content, user_generated: true)
  end

  def message_id
    params["MessageID"]
  end

  def in_reply_to
    params["InReplyTo"]
  end

  def raw_content
    params["TextBody"] || params["HtmlBody"]
  end

  def message_content
    raw_content.to_s.squish
  end
end