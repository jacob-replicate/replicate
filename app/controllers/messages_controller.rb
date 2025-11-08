class MessagesController < ApplicationController
  def create
    conversation = Conversation.where(channel: :web).find_by(id: params[:conversation_id])
    return head :not_found unless conversation.present?

    return head :ok if params[:content].to_s.include?("isTrusted")

    if conversation.messages.count == 5
      SendAdminPushNotification.call("New Conversation", params[:content])
    end

    message = params[:content]
    conversation_ids = Conversation.where(ip_address: request.remote_ip).pluck(:id)
    total_messages = Message.where(conversation_id: conversation_ids)
    duplicate_message = conversation.messages.where(content: message).count >= 3 && message.exclude?("hint") && message.exclude?("What am I missing")
    if duplicate_message || total_messages.user.where("created_at > ?", 1.minute.ago).count > 12 || message.length > 800
      ban_current_ip
      return head(:ok)
    end

    message = conversation.messages.create!(content: params[:content], user_generated: true, suggested: params[:suggested].present?)
    head :ok
  end
end