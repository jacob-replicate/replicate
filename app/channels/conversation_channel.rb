class ConversationChannel < ApplicationCable::Channel
  def subscribed
    conversation = Conversation.find_by(id: params[:id])

    if conversation.web?
      stream_for conversation

      if conversation.messages.count == 0
        initial_message = conversation.context["initial_message"]
        if initial_message.present?
          conversation.messages.create!(content: initial_message, user_generated: true)
        else
          ConversationDriverWorker.perform_async(conversation.id)
        end
      end
    else
      reject
    end
  end
end