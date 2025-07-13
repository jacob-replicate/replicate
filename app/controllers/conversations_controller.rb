class ConversationsController < ApplicationController
  def create
    return start_conversation(
      context: {
        conversation_type: :landing_demo,
        initial_message: "**What caught you by surprise recently?**<br>#{params[:initial_message]}"
      }
    )
  end

  def show
    @conversation = Conversation.find(params[:id])
  end
end