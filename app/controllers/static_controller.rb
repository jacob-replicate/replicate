class StaticController < ApplicationController
  before_action :set_prices
  before_action :verify_admin, only: [:growth]

  def index
    create_sev
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

    if params[:ip].present?
      @base_conversations = @base_conversations.where(ip_address: params[:ip])
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
    create_sev
    redirect_to conversation_path(@conversation)
  end

  def security
    @title = "Security"
  end

  def difficulty
    session[:difficulty] = params[:difficulty].to_s.downcase
    redirect_to "/sev"
  end

  def difficulty_prompts
    {
      "junior" => "You're working with a junior full-stack engineer. Keep it friendly, concrete, and free of jargon. Talk about systems at a conceptual level, what's happening and why, without deep protocol or infra details. Think mentorship, not mastery. They don't know the big words yet. Don't use them. Assume they suck at resolving SEV-1 incidents. You need to hand-hold.",
      "mid" => "You’re working with a mid-level engineer. Assume they know the basics but not the edge cases. Use plain technical terms and connect each detail to practical outcomes. Explain tradeoffs and reliability patterns without diving into deep distributed systems theory. They're stronger than juniors, but not by much yet.",
      "senior" => "You're talking to a senior engineer. Skip the hand-holding. Assume fluency in systems, networking, and incident response. Use concise technical language and emphasize nuance, where guarantees break, where intuition fails, and how design choices cascade under load.",
      "staff" => "You’re working with a Staff+ engineer. Treat them as a peer. Be exact, economical, and challenging. Focus on causal reasoning, trust boundaries, and system failure modes. Assume they see through hand-waving. Precision and insight matter more than style."
    }
  end

  def create_sev
    difficulty_level = [session[:difficulty], "senior"].reject(&:blank?).first

    context = {
      conversation_type: :coaching,
      difficulty: difficulty_level,
      difficulty_prompt: difficulty_prompts[difficulty_level],
      incident: (WEB_INCIDENTS + INCIDENTS.map { |i| i["prompt"] }).sample
    }

    @conversation = Conversation.create!(context: context, channel: "web")
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