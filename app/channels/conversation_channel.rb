class ConversationChannel < ApplicationCable::Channel
  def subscribed
    conversation = Conversation.find_by(id: params[:id])

    if conversation.present?
      stream_for conversation

      if conversation.messages.count == 0
        ConversationDriverWorker.perform_async(conversation.id)
      end
    else
      reject
    end
  end
end