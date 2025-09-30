class SessionsController < ApplicationController
  def pulse
    id = params[:id]
    session = id.present? ? Session.find_by(id: id) : Session.new
    session.save!

    session.update(
      ip: request.remote_ip,
      page: params[:page],
      referring_page: params[:referring_page],
      duration: (Time.now - session.created_at).seconds,
      user_agent: request.user_agent
    )

    render json: { id: session.id }
  end
end