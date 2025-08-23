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

  def demo
    return start_conversation(
      context: {
        conversation_type: :landing_demo,
        engineer_name: "Alex Shaw",
        first_name: "Alex",
        incident: WEB_INCIDENTS.sample
      },
      force_tos: true
    )
  end

  def coaching
    name = ["Alex Shaw", "Taylor Morales", "Casey Patel"].sample
    first_name = name.split.first

    return start_conversation(
      context: {
        conversation_type: :coaching,
        engineer_name: name,
        first_name: first_name,
        incident: WEB_INCIDENTS.sample
      },
      force_tos: true
    )
  end

  def security
    @title = "Security"
  end

  def knowledge_gaps
    redirect_to "https://docs.google.com/document/d/1YSmtsZYZ6qJrTOv4raqOUcU2Q1YvrVTzlab9QjUFT50/edit", allow_other_host: true
  end

  def set_prices
    @prices = [
      { seat_count: 25,  price: 20_000 },
      { seat_count: 75,  price: 40_000 },
      { seat_count: 150, price: 80_000 },
      { seat_count: 300, price: 120_000 },
      { seat_count: 1_000, price: 240_000 }
    ]
  end
end