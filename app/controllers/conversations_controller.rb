class ConversationsController < ApplicationController
  def create
    user = current_user || create_guest_user
    @conversation = Conversation.create!(user: user, category: :landing_page)

    SendMessageWorker.new.perform(@conversation.id, "**What fire did you put out recently?**\n#{params[:initial_message]}", user.id)

    if params[:agree].present?
      redirect_to conversation_path(@conversation)
    else
      redirect_to conversation_path(@conversation, require_tos: true)
    end
  end

  def show
    @conversation = Conversation.find(params[:id])

    if @conversation.user.present? && @conversation.user != current_user
      flash[:alert] = "You are not authorized to view this conversation."
      redirect_to root_path
    end
  end
end