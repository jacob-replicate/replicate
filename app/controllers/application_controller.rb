class ApplicationController < ActionController::Base
  private

  def create_guest_user
    user = User.create!(name: "Anonymous", email: "placeholder+#{SecureRandom.hex(10)}@replicate.info", password: SecureRandom.hex(10))
    sign_in user
  end
end