class TopicsController < ApplicationController
  before_action :verify_admin, only: [:populate]

  def show
    @topic = Topic.includes(:conversations).find_by!(code: params[:code])
    @conversations = @topic.conversations.templates.order(:name)
    @conversation_count = @conversations.size
    @populated_count = @conversations.populated.size

    owner_type, owner_id = current_owner
    @visited_codes = @topic.conversations.where(template: false, owner_type: owner_type, owner_id: owner_id).pluck(:code).to_set
    @completed_count = @visited_codes.size

    render json: {
      topic_state: @topic.state,
      topic_name: @topic.name,
      topic_description: @topic.description,
      conversation_count: @conversation_count,
      populated_count: @populated_count,
      completed_count: @completed_count,
      conversations: @conversations.map do |convo|
        {
          code: convo.code,
          name: convo.name,
          description: convo.description,
          state: convo.state,
          visited: @visited_codes.include?(convo.code),
          url: topic_conversation_path(@topic.code, convo.code)
        }
      end
    }
  end

  def populate
    @topic = Topic.find_by!(code: params[:code])
    @topic.update!(state: "populating")
    PopulateTopicWorker.perform_async(@topic.id)
    respond_to do |format|
      format.html { redirect_to topic_path(@topic.code) }
      format.json { head :ok }
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
end