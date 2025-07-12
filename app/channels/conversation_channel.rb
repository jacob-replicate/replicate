class ConversationChannel < ApplicationCable::Channel
  def subscribed
    conversation = Conversation.find_by(id: params[:id])

    if conversation&.recipient == current_user
      stream_for conversation

      if conversation.messages.count == 0
        initial_message = conversation.context["initial_message"]
        if initial_message.present?
          SendMessageWorker.perform_async(conversation.id, initial_message, true)
          session[:initial_message] = nil
        elsif conversation.messages.count == 0
          SendMessageWorker.perform_async(conversation.id)
        end
      end
    else
      reject
    end
  end
end