class TopicsController < ApplicationController
  before_action :verify_admin, only: [:populate]

  def index
    @topics = Topic.all.order(:name)
  end

  def show
    @topic = Topic.includes(:experiences).find_by!(code: params[:code])
    @experiences = @topic.experiences.templates.order(:name)
    @experience_count = @experiences.size
    @forked_experience_codes = @topic.experiences.where(template: false, session_id: session[:identifier]).pluck(:code).to_set
    @completed_count = @forked_experience_codes.size
  end

  def populate
    @topic = Topic.find_by!(code: params[:code])
    PopulateTopicWorker.perform_async(@topic.id)
    redirect_to topic_path(@topic.code), notice: "Populating #{@topic.name}..."
  end
end