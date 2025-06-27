class ConversationChannel < ApplicationCable::Channel
  def subscribed
    conversation = Conversation.find_by(id: params[:id])

    if conversation&.user == current_user
      stream_for conversation
    else
      reject
    end
  end
end