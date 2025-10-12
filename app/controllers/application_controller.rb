class ApplicationController < ActionController::Base
  skip_before_action :verify_authenticity_token

  private

  def verify_admin
    raise "Not found" unless (request.remote_ip == "98.249.45.68" || Rails.env.development?)
  end
end