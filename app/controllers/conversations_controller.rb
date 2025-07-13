class ConversationsController < ApplicationController
  def create
    return start_conversation(
      context: {
        conversation_type: :landing_demo,
        initial_message: "<div>#{params[:initial_message]}</div>"
      }
    )
  end

  def show
    @conversation = Conversation.find(params[:id])
  end
end