class ApplicationController < ActionController::Base
  before_action :skip_malicious_users
  before_action :set_session_identifier
  helper_method :admin?, :current_user, :logged_in?

  rescue_from ActionController::InvalidAuthenticityToken do |exception|
    Rails.logger.info "Blocked CSRF from #{request.remote_ip} ua=#{request.user_agent}"
    head :ok
  end

  private

  def set_session_identifier
    session[:identifier] ||= SecureRandom.hex(10)
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in?
    current_user.present?
  end

  def admin?
    return true if current_user&.admin?
    false
  end

  def skip_malicious_users
    return if request.remote_ip == "98.249.45.68"
    return if Rails.env.development?

    if banned_ips.include?(request.remote_ip)
      Rails.logger.info "Blocking request from banned IP #{request.remote_ip}"
      return head(:ok)
    end

    if Rails.cache.increment("req:#{request.remote_ip}", 1, expires_in: 1.minute).to_i > 30
      Rails.logger.info "Blocking excessive requests from #{request.remote_ip}"
      # ban_current_ip
      return head :ok
    end

    ua     = request.user_agent.to_s
    accept = request.headers['Accept'].to_s

    # allow internal/health checks and known good bots
    return if ['127.0.0.1', '::1'].include?(request.remote_ip)
    return if ua =~ /Googlebot|Bingbot|Slackbot|Healthcheck|Reddit/i

    non_browser = /\b(curl|wget|python-requests|httpie|go-http-client|libwww-perl|php\/|java\/|okhttp|postmanruntime|axios|node-fetch|fetch)\b/i

    if (ua.blank? || ua.match?(non_browser) || ua.length < 10) && !accept.include?('text/html')
      Rails.logger.info "Non-browser request from #{request.remote_ip} ua=#{ua.inspect} accept=#{accept.inspect}"
      # ban_current_ip
      return head(:ok)
    end

    nil
  end

  def banned_ips
    time_range = Rails.env.development? ? 10.seconds.ago : 1.week.ago
    [
      '35.146.19.108',
      '149.34.244.133',
      '209.127.202.113'
    ] + BannedIp.where("created_at > ?", time_range).pluck(:address)
  end

  def ban_current_ip
    return if user_signed_in? && current_user.admin?
    Rails.logger.info "Banning IP #{request.remote_ip}"
    BannedIp.create!(address: request.remote_ip) unless banned_ips.include?(request.remote_ip)
  end

  def verify_admin
    raise "Not found" unless admin?
  end
end