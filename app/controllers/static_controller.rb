class StaticController < ApplicationController
  before_action :set_prices

  def index
    context = {
      conversation_type: :coaching,
      incident: (INCIDENTS - [INCIDENTS[3]]).sample["prompt"]
    }

    @conversation = Conversation.create!(context: context, channel: "web")
  end

  def growth
    return head(:not_found) unless params[:code] == "stats"

    @relevant_contacts = Contact.where.not(contacted_at: nil)
    @unsubscribes = Contact.where(unsubscribed: true)
    @remaining_contacts = Contact.enriched.us.where(email_queued_at: nil).where("score >= 90")
    @relevant_messages = Message.where(user_generated: true).where.not(content: "Give me a hint")
    @base_conversations = Conversation.where(id: @relevant_messages.select(:conversation_id).distinct)
    @web_conversations = @base_conversations.where(channel: "web")
    @web_messages = Message.where(conversation_id: @web_conversations.map(&:id), user_generated: true).where.not(content: "Give me a hint")
    @email_conversations = Conversation.where(channel: "email")
    @email_messages = Message.where(conversation_id: @email_conversations.pluck(:id), user_generated: true)
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