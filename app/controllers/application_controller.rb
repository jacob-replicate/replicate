class ApplicationController < ActionController::Base
  def start_conversation(initial_message: nil, context: {}, force_tos: false)
    user = current_user || create_guest_user
    @conversation = Conversation.create!(recipient: user, context: context, channel: :web)

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