class ConversationsController < ApplicationController
  def create
    @conversation = Conversation.create!(user: current_user || create_guest_user)
    redirect_to conversation_path(@conversation)
  end

  def show
    @conversation = Conversation.find(params[:id])

    if @conversation.user.present? && @conversation.user != current_user
      flash[:alert] = "You are not authorized to view this conversation."
      redirect_to root_path
    end
  end
end