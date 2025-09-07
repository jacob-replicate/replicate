class ProcessPostmarkWebhookWorker
  include Sidekiq::Worker

  sidekiq_options retry: false, lock: :until_executed

  def perform(webhook_id)
    webhook = PostmarkWebhook.find_by(id: webhook_id)
    return unless webhook.present?

    webhook.update!(processed_at: Time.current)
    return
  end

  private

  def sender_matches?(conversation)
    sender = params.dig("FromFull", "Email") || params["From"]
    return false if sender.blank?

    sender.downcase.strip == conversation.recipient.email.downcase.strip
  end

  def duplicate_message?(conversation)
    conversation.messages.exists?(content: message_content, user_generated: true)
  end

  def rate_limited?(conversation_id)
    key = "postmark/conversation:#{conversation_id}/rate"
    limit = 10
    window = 1.minute

    Rails.cache.increment(key, 1, expires_in: window) > limit
  end
end