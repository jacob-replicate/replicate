class MessagesController < ApplicationController
  def create
    return head :unauthorized unless user_signed_in?

    conversation = current_user.conversations.find_by(id: params[:conversation_id])
    return head :not_found unless conversation.present?

    message = conversation.messages.create!(content: params[:content], user_generated: true)
    head :ok
  end
end