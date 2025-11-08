class ApplicationController < ActionController::Base
  before_action :skip_blocked_ips
  skip_before_action :verify_authenticity_token

  private

  def skip_blocked_ips
    return head(:not_found) if request.remote_ip == '35.146.19.108'
  end

  def verify_admin
    raise "Not found" unless (request.remote_ip == "98.249.45.68" || Rails.env.development?)
  end
end