class ConversationsController < ApplicationController
  def create
    return start_conversation(
      context: {
        conversation_type: :landing_page,
        initial_message: "**What fire did your team put out recently?**<br>#{params[:initial_message]}"
      }
    )
  end

  def show
    @conversation = Conversation.find(params[:id])

    if @conversation.messages.count > 1
      # return redirect_to "/query-spike"
    end
  end
end