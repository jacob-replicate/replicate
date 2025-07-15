class ConversationsController < ApplicationController
  def create
    engineer_name = params[:engineer_name] || "Alex Shaw"
    first_name = engineer_name.split.first
    return start_conversation(
      context: {
        conversation_type: :landing_demo,
        engineer_name: engineer_name,
        first_name: first_name,
        incident: params[:incident]
      }
    )
  end

  def show
    @conversation = Conversation.find(params[:id])
  end
end