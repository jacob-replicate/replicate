class ExperiencesController < ApplicationController
  protect_from_forgery with: :null_session

  def show
    template = Experience.templates.find_by(code: params[:code])

    if template.present?
      @experience = template.fork!(session[:identifier])
    else
      redirect_to root_path
    end
  end
end