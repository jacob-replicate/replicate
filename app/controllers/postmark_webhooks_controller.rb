class PostmarkWebhooksController < ApplicationController
  def create
    return head :unauthorized unless valid_ip_address?

    conversation_id = params["InReplyTo"].downcase.gsub(/.*conversation-/, "").gsub(/@replicate\.info.*/, "")
    conversation = Conversation.find_by(id: conversation_id)
    webhook = PostmarkWebhook.create!(conversation: conversation, content: params.to_unsafe_h)
    ProcessPostmarkWebhookWorker.perform_async(webhook.id)

    head :ok
  end
end