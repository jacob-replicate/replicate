class MissiveWebhooksController < ApplicationController
  def create
    webhook = MissiveWebhook.create!(content: request.request_parameters.deep_stringify_keys)
    SendAdminPushNotification.call("Cold Email Reply", "Go check it out")
    head :ok
  end
end