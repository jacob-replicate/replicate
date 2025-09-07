class ProcessPostmarkWebhookWorker
  include Sidekiq::Worker

  sidekiq_options retry: false, lock: :until_executed

  def perform(webhook_id, force = false)
    webhook = PostmarkWebhook.find_by(id: webhook_id)
    return unless webhook.present? && (webhook.processed_at.nil? || force)

    original_message = webhook.in_reply_to_message
    if original_message.present?
      conversation = original_message.conversation
      conversation.messages.create!(content: webhook.message, user_generated: true, email_message_id_header: webhook.rfc_message_id)
    end

    webhook.update!(processed_at: Time.current)
  end
end