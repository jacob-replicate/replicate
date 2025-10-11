class MessagesController < ApplicationController
  def create
    conversation = Conversation.where(channel: :web).find_by(id: params[:conversation_id])
    return head :not_found unless conversation.present?

    return head :ok if params[:content].to_s.include?("isTrusted")

    message = conversation.messages.create!(content: params[:content], user_generated: true)
    head :ok
  end
end