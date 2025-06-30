class MessagesController < ApplicationController
  def create
    return head :unauthorized unless user_signed_in?

    conversation = current_user.conversations.find_by(id: params[:conversation_id])
    return head :not_found unless conversation.present?

    SendWebMessageWorker.perform_async(conversation.id, params[:content], current_user.id)
    head :ok
  end
end