class ConversationsController < ApplicationController
  def create
    return redirect_to_demo_conversation(initial_message: params[:initial_message])
  end

  def show
    @conversation = Conversation.find(params[:id])

    if @conversation.recipient.present? && @conversation.recipient != current_user
      flash[:alert] = "You are not authorized to view this conversation."
      redirect_to root_path
    end
  end
end