class StaticController < ApplicationController
  before_action :set_prices

  def index
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
    name = ["Alex Shaw", "Taylor Morales", "Casey Patel"].sample
    first_name = name.split.first

    return start_conversation(
      context: {
        conversation_type: :coaching,
        engineer_name: name,
        first_name: first_name,
        incident: INCIDENTS.sample["prompt"]
      },
      force_tos: true
    )
  end

  def security
    @title = "Security"
  end

  def set_prices
    @prices = [
      { seat_count: 25,  price: 10_000 },
      { seat_count: 75,  price: 20_000 },
      { seat_count: 150, price: 30_000 },
      { seat_count: 300, price: 40_000 },
      { seat_count: 500, price: 50_000 }
    ]
  end
end