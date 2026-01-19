class ExperiencesController < ApplicationController
  protect_from_forgery with: :null_session

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
end