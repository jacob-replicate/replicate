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

  def oauth_create
    auth = request.env['omniauth.auth']

    # Security: Verify we got valid auth data
    if auth.nil? || auth.info.nil? || auth.info.email.blank?
      return redirect_to root_path, alert: "Authentication failed"
    end

    user = User.find_or_create_by(provider: auth.provider, uid: auth.uid) do |u|
      u.email = auth.info.email
      u.name = auth.info.name
      u.avatar_url = auth.info.image
    end

    user.update(
      email: auth.info.email,
      name: auth.info.name,
      avatar_url: auth.info.image
    )

    # Transfer any session-owned conversations to the user
    if session[:identifier].present?
      Conversation.transfer_session_to_user(session[:identifier], user)
    end

    session[:user_id] = user.id
    redirect_to root_path
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path
  end

  def oauth_failure
    redirect_to root_path, alert: "Authentication failed"
  end
end