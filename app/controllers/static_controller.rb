class StaticController < ApplicationController
  before_action :verify_admin, only: [:growth]

  def index
    topics = Topic.includes(:conversations).order(:name)
    topic_categories = TopicCategories.new(topics)

    @categories = topic_categories.categorized
    @uncategorized_topics = topic_categories.uncategorized

    # Preload conversation templates
    @conversations_by_topic = Conversation.templates
      .where(topic_id: topics.pluck(:id))
      .order(:name)
      .group_by(&:topic_id)

    # User's visited conversations (forked from templates)
    owner_type, owner_id = current_owner
    @visited_codes_by_topic = Conversation
      .where(template: false, topic_id: topics.pluck(:id), owner_type: owner_type, owner_id: owner_id)
      .pluck(:topic_id, :code)
      .group_by(&:first)
      .transform_values { |pairs| pairs.map(&:last).to_set }

    if request.xhr?
      json_data = build_graph_json
      render json: json_data
    end
  end

  private

  def current_owner
    if current_user
      ["User", current_user.id.to_s]
    else
      ["Session", session[:identifier]]
    end
  end

  def build_graph_json
    data = {
      is_admin: admin?,
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
    conversations = @conversations_by_topic[topic.id] || []
    visited_codes = @visited_codes_by_topic[topic.id] || Set.new
    populated_conversations = conversations.select { |c| c.state == 'populated' }

    {
      code: topic.code,
      name: topic.name,
      description: topic.description,
      state: topic.state,
      url: topic_path(topic.code),
      conversation_count: conversations.size,
      populated_count: populated_conversations.size,
      completed_count: visited_codes.size,
      conversations: conversations.map { |convo| conversation_json(convo, visited_codes, topic) }
    }
  end

  def conversation_json(convo, visited_codes, topic)
    {
      code: convo.code,
      name: convo.name,
      description: convo.description,
      state: convo.state,
      visited: visited_codes.include?(convo.code),
      url: topic_conversation_path(topic.code, convo.code)
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