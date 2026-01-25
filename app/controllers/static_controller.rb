class StaticController < ApplicationController
  before_action :verify_admin, only: [:growth]

  def index
    topics = Topic.includes(:experiences).order(:name)
    topic_categories = TopicCategories.new(topics)

    @categories = topic_categories.categorized
    @uncategorized_topics = topic_categories.uncategorized

    # Preload all experience data for efficiency
    @experiences_by_topic = Experience.templates
      .where(topic_id: topics.pluck(:id))
      .order(:name)
      .group_by(&:topic_id)

    # User's completed experiences (forked from templates)
    @forked_codes_by_topic = Experience
      .where(template: false, topic_id: topics.pluck(:id), session_id: session[:identifier])
      .pluck(:topic_id, :code)
      .group_by(&:first)
      .transform_values { |pairs| pairs.map(&:last).to_set }

    if request.xhr?
      json_data = build_graph_json
      render json: json_data
    end
  end

  private

  def build_graph_json
    data = {
      categories: @categories.map { |cat| category_json(cat) },
      uncategorized: @uncategorized_topics.map { |t| topic_json(t) }
    }

    # Checksum based on states + counts for efficient polling
    checksum_source = data.to_json
    data[:checksum] = Digest::MD5.hexdigest(checksum_source)[0, 8]
    data
  end

  def category_json(category)
    {
      name: category.name,
      topics: category.topics.map { |t| topic_json(t) }
    }
  end

  def topic_json(topic)
    experiences = @experiences_by_topic[topic.id] || []
    forked_codes = @forked_codes_by_topic[topic.id] || Set.new

    populated_experiences = experiences.select { |e| e.state == 'populated' }

    {
      code: topic.code,
      name: topic.name,
      description: topic.description,
      state: topic.state,
      url: topic_path(topic.code),
      experience_count: experiences.size,
      populated_count: populated_experiences.size,
      completed_count: forked_codes.size,
      experiences: experiences.map { |exp| experience_json(exp, forked_codes) }
    }
  end

  def experience_json(exp, forked_codes)
    {
      code: exp.code,
      name: exp.name,
      description: exp.description,
      state: exp.state,
      visited: forked_codes.include?(exp.code),
      url: topic_experience_path(exp.topic.code, exp.code)
    }
  end

  public

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