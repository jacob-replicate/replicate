class ExperiencesController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :verify_admin, only: [:populate, :destroy]

  def show
    @topic = Topic.find_by!(code: params[:topic_code])
    experience_code = params[:experience_code] || params[:code]

    template = Experience.templates.includes(:topic).find_by(code: experience_code)

    if template.present?
      @experience = template.fork!(session[:identifier])
    else
      redirect_to root_path
    end
  end

  def populate
    @topic = Topic.find_by!(code: params[:topic_code])
    @experience = Experience.templates.find_by!(code: params[:experience_code])
    @experience.update!(state: "populating")
    PopulateExperienceWorker.perform_async(@experience.id)
    redirect_to topic_path(@topic.code)
  end

  def destroy
    @topic = Topic.find_by!(code: params[:topic_code])
    @experience = Experience.templates.find_by!(code: params[:experience_code])
    experience_name = @experience.name
    @experience.destroy!
    redirect_to topic_path(@topic.code), notice: "#{experience_name} deleted."
  end
end