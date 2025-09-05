class PostmarkWebhooksController < ApplicationController
  def create
    return head :unauthorized unless valid_ip_address?

    webhook = PostmarkWebhook.create!(content: request.request_parameters.deep_stringify_keys)
    ProcessPostmarkWebhookWorker.perform_async(webhook.id)

    head :ok
  end

  private

  def valid_ip_address?
    valid_ips = [
      "3.134.147.250",
      "50.31.156.6",
      "50.31.156.77",
      "18.217.206.57"
    ]

    valid_ips.include?(request.remote_ip)
  end
end