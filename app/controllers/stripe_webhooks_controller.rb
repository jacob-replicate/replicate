class StripeWebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    payload = request.body.read
    signature = request.headers["HTTP_STRIPE_SIGNATURE"]
    endpoint_secret = ENV["STRIPE_WEBHOOK_SECRET"]

    begin
      event = Stripe::Webhook.construct_event(payload, signature, endpoint_secret)
    rescue Stripe::SignatureVerificationError => e
      return head :bad_request
    end

    case event.type
      when 'charge.refunded'
        # TODO: Do something
    end

    head :ok
  end
end