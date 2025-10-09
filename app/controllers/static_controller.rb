class StaticController < ApplicationController
  before_action :set_prices

  def index
    context = {
      conversation_type: :coaching,
      incident: INCIDENTS[4]["prompt"]
    }

    @conversation = Conversation.create!(context: context, channel: "web")
  end

  def terms
    @title = "Terms of Service"
  end

  def privacy
    @title = "Privacy Policy"
  end

  def billing
    @title = "Billing"
  end

  def coaching
    context = {
      conversation_type: :coaching,
      incident: WEB_INCIDENTS.sample
    }

    @conversation = Conversation.create!(context: context, channel: "web")
    redirect_to conversation_path(@conversation, require_tos: true)
  end

  def security
    @title = "Security"
  end

  def set_prices
    @prices = [
      { seat_count: 10,  price: 10_000 },
      { seat_count: 25,  price: 20_000 },
      { seat_count: 75,  price: 30_000 },
      { seat_count: 150, price: 40_000 },
      { seat_count: 500, price: 50_000 },
    ]; @prices.map { |x| x[:price] / x[:seat_count] }
  end
end