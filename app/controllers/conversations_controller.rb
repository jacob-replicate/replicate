class ConversationsController < ApplicationController
  def create
    return redirect_to_demo_conversation(initial_message: "**What fire did your team put out recently?**\n#{params[:initial_message]}")
  end

  def show
    @conversation = Conversation.find(params[:id])

    if @conversation.messages.count > 1
      # return redirect_to "/query-spike"
    end

    if session[:initial_message].present?
      SendWebMessageWorker.new.perform(@conversation.id, session[:initial_message], current_user.id)
      session[:initial_message] = nil
    end
  end
end