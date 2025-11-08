class ApplicationController < ActionController::Base
  before_action :skip_malicious_users
  skip_before_action :verify_authenticity_token

  private

  def skip_malicious_users
    return head(:not_found) if banned_ips.include?(request.remote_ip)

    ua     = request.user_agent.to_s
    accept = request.headers['Accept'].to_s

    # allow internal/health checks and known good bots
    return if ['127.0.0.1', '::1'].include?(request.remote_ip)
    return if ua =~ /Googlebot|Bingbot|Slackbot|Healthcheck/i

    non_browser = /\b(curl|wget|python-requests|httpie|go-http-client|libwww-perl|php\/|java\/|okhttp|postmanruntime|axios|node-fetch|fetch)\b/i

    # quick heuristics: block only when UA looks like a CLI and the request is not asking for HTML
    if (ua.blank? || ua.match?(non_browser) || ua.length < 10) && !accept.include?('text/html')
      Rails.logger.info "Blocking non-browser request from #{request.remote_ip} ua=#{ua.inspect} accept=#{accept.inspect}"
      return head(:not_found)
    end

    nil
  end

  def verify_admin
    raise "Not found" unless (request.remote_ip == "98.249.45.68" || Rails.env.development?)
  end

  def banned_ips
    [
      '35.146.19.108',
      '149.34.244.133',
      '209.127.202.113'
    ]
  end
end