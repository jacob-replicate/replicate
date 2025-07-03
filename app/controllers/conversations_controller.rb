class ConversationsController < ApplicationController
  def create
    user = current_user || create_guest_user
    @conversation = Conversation.create!(recipient: user, category: :landing_page)

    SendWebMessageWorker.new.perform(@conversation.id, "**What issue disrupted your team recently?**\n#{params[:initial_message]}", user.id)

    if EXAMPLE_EMAILS.map { |email| email[:prompt] }.include?(params[:initial_message]).present?
      redirect_to conversation_path(@conversation, require_tos: true)
    else
      redirect_to conversation_path(@conversation)
    end
  end

  def show
    @conversation = Conversation.find(params[:id])

    if @conversation.recipient.present? && @conversation.recipient != current_user
      flash[:alert] = "You are not authorized to view this conversation."
      redirect_to root_path
    end
  end
end