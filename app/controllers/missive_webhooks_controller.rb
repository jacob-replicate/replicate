class MissiveWebhooksController < ApplicationController
  def create
    webhook_content = request.request_parameters.deep_stringify_keys
    webhook = MissiveWebhook.create!(content: webhook_content)

    sender = webhook_content["message"]["from_field"]["name"]
    message = webhook_content["message"]["preview"]
    SendAdminPushNotification.call(sender, message)
    head :ok
  end
end