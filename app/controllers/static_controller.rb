class StaticController < ApplicationController
  before_action :verify_admin, only: [:growth]

  def index
    topics = Topic.all.order(:name)
    topic_categories = TopicCategories.new(topics)

    @categories = topic_categories.categorized
    @uncategorized_topics = topic_categories.uncategorized

    # Progress data for each topic (completed / total experiences)
    if Rails.env.development?
      # Fake data for development
      @topic_progress = topics.each_with_object({}) do |topic, hash|
        total = rand(8..20)
        completed = rand(0..total)
        hash[topic.id] = { completed: completed, total: total }
      end
    else
      # Real counts in production (single query)
      experience_counts = Experience.templates.where(topic_id: topics.pluck(:id)).group(:topic_id).count
      @topic_progress = topics.each_with_object({}) do |topic, hash|
        total = experience_counts[topic.id] || 0
        completed = 0 # TODO: Replace with real session-based progress tracking
        hash[topic.id] = { completed: completed, total: total }
      end
    end
  end

  def growth
    @active_trials = Member.where(subscribed: true).pluck(:organization_id).uniq.size # TODO: Filter out auto-unsubscribed
    @relevant_messages = Message.where(user_generated: true)
    @base_conversations = Conversation.where(id: @relevant_messages.select(:conversation_id).distinct)

    if params[:start].present?
      @base_conversations = @base_conversations.where("created_at > ?", Time.at(params[:start].to_i))
    end

    if params[:min].present?
      valid_ids = @relevant_messages.group(:conversation_id).count.select { |k, v| v >= params[:min].to_i }.map(&:first)
      @base_conversations = @base_conversations.where(id: valid_ids)
    end

    if params[:ip].present?
      @base_conversations = Conversation.where(ip_address: params[:ip])
    end

    @counts_by_ip_address = @base_conversations.group(:ip_address).count.to_h

    @conversations = @base_conversations
    @messages = Message.where(conversation_id: @conversations.map(&:id), user_generated: true).where.not(content: "Give me a hint")
    @duration = @conversations.count == 0 ? 0 : @conversations.map(&:duration).reject(&:blank?).sum / @conversations.size.to_f

    @stats = {
      conversations: "#{@conversations.count} - #{(@messages.count.to_f / @conversations.count).round(2)} - #{@duration.to_f.round}min",
      banned_ips: BannedIp.count
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

  def security
    @title = "Security"
  end
end