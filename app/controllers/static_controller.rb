class StaticController < ApplicationController
  before_action :set_prices
  before_action :verify_admin, only: [:growth]

  def index
    context = {
      conversation_type: :coaching,
      incident: (WEB_INCIDENTS + INCIDENTS.map { |i| i["prompt"] }).sample
    }

    @conversation = Conversation.create!(context: context, channel: "web", ip_address: request.remote_ip)
  end

  def growth
    @active_trials = Member.where(subscribed: true).pluck(:organization_id).uniq.size # TODO: Filter out auto-unsubscribed
    @relevant_messages = Message.where(user_generated: true)
    @base_conversations = Conversation.where(id: @relevant_messages.select(:conversation_id).distinct)
    @counts_by_ip_address = @base_conversations.group(:ip_address).count.to_h

      if params[:min].present?
      valid_ids = @relevant_messages.group(:conversation_id).count.select { |k, v| v >= params[:min].to_i }.map(&:first)
      @base_conversations = @base_conversations.where(id: valid_ids)
    end


    @web_conversations = @base_conversations.where(channel: "web")
    @web_messages = Message.where(conversation_id: @web_conversations.map(&:id), user_generated: true).where.not(content: "Give me a hint")
    @web_duration = @web_conversations.count == 0 ? 0 : @web_conversations.map(&:duration).reject(&:blank?).sum / @web_conversations.size.to_f
    @email_conversations = Conversation.where(channel: "email", id: @relevant_messages.pluck(:conversation_id).uniq)
    @email_messages = Message.where(conversation_id: @email_conversations.pluck(:id), user_generated: true)

    @stats = {
      web_threads: "#{@web_conversations.count} - #{(@web_messages.count.to_f / @web_conversations.count).round(2)} - #{@web_duration.to_f.round}min",
      email_threads: "#{@email_conversations.count} (#{(@email_messages.count.to_f / @email_conversations.count).round(2)})",
      active_trials: "#{@active_trials} (#{Member.where(subscribed: true).count})",
      active_customers: "0 ($0)",
    }
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
      incident: (WEB_INCIDENTS + INCIDENTS.map { |i| i["prompt"] }).sample
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