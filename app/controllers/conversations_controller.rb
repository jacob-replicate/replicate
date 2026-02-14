class ConversationsController < ApplicationController
  before_action :verify_admin, only: [:destroy, :populate, :destroy_template]

  # GET /conversations/:id
  def show
    @conversation = Conversation.find_by(id: params[:id])

    if @conversation.blank? && params[:sharing_code].present?
      @conversation = Conversation.fork(params[:sharing_code])
      @conversation.update(ip_address: request.remote_ip)
    end

    if @conversation.blank?
      return redirect_to root_path
    end

    @topic = @conversation.topic

    @title = [@conversation.page_title || @conversation.name, "replicate.info"].reject(&:blank?).first
  end

  # GET /:topic_code/:conversation_code - Show by topic/code (forks template if needed)
  def show_by_code
    @topic = Topic.find_by!(code: params[:topic_code])
    template = @topic.conversations.templates.find_by!(code: params[:conversation_code])

    # Fork the template for the current user/session
    owner_type, owner_id = current_owner
    @conversation = template.fork_for_owner!(owner_type: owner_type, owner_id: owner_id)
    @conversation.update(ip_address: request.remote_ip) if @conversation.ip_address.blank?

    @title = [@conversation.name, "replicate.info"].reject(&:blank?).first
    render :show
  end

  # POST /:topic_code/:conversation_code/populate
  def populate
    @topic = Topic.find_by!(code: params[:topic_code])
    @conversation = @topic.conversations.templates.find_by!(code: params[:conversation_code])
    @conversation.update!(state: "populating")
    PopulateConversationWorker.perform_async(@conversation.id)
    respond_to do |format|
      format.html { redirect_to topic_path(@topic.code) }
      format.json { head :ok }
    end
  end

  # DELETE /:topic_code/:conversation_code
  def destroy_template
    @topic = Topic.find_by!(code: params[:topic_code])
    @conversation = @topic.conversations.templates.find_by!(code: params[:conversation_code])
    @conversation.destroy!
    head :no_content
  end

  def update
    @conversation = Conversation.find(params[:id])
  end

  # Admin only
  def destroy
    @conversation = Conversation.find(params[:id])
    @conversation.destroy
    redirect_to "/growth"
  end

  private

  def current_owner
    if current_user
      ["User", current_user.id.to_s]
    else
      ["Session", session[:identifier]]
    end
  end
end