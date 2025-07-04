class ApplicationController < ActionController::Base
  def redirect_to_demo_conversation(initial_message:, force_tos: false)
    raise if initial_message.blank?
    user = current_user || create_guest_user
    @conversation = Conversation.create!(recipient: user, category: :landing_page)

    SendWebMessageWorker.new.perform(@conversation.id, "**What issue disrupted your team recently?**\n#{initial_message}", user.id)

    if force_tos || EXAMPLE_EMAILS.map { |email| email[:prompt] }.include?(initial_message).present?
      redirect_to conversation_path(@conversation, require_tos: true)
    else
      redirect_to conversation_path(@conversation)
    end
  end

  private

  def create_guest_user
    return if user_signed_in?

    user = User.create!(name: "Anonymous", email: "placeholder+#{SecureRandom.hex(10)}@replicate.info", password: SecureRandom.hex(10))
    sign_in user
  end
end