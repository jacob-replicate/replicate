class TopicsController < ApplicationController


  def show
    @topic = Topic.includes(:experiences).find_by!(code: params[:code])
    @experiences = @topic.experiences.templates.order(:name)
    @experience_count = @experiences.size
    @populated_count = @experiences.populated.size
    @forked_experience_codes = @topic.experiences.where(template: false, session_id: session[:identifier]).pluck(:code).to_set
    @completed_count = @forked_experience_codes.size

    # Only respond to xhr requests - navigation is handled client-side
    render json: {
      topic_state: @topic.state,
      topic_name: @topic.name,
      topic_description: @topic.description,
      experience_count: @experience_count,
      populated_count: @populated_count,
      completed_count: @completed_count,
      experiences: @experiences.map do |exp|
        {
          code: exp.code,
          name: exp.name,
          description: exp.description,
          state: exp.state,
          visited: @forked_experience_codes.include?(exp.code),
          url: topic_experience_path(@topic.code, exp.code)
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
end