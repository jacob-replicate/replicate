class ConversationsController < ApplicationController
  def create
    hardcoded_flow_messages = [
      "critical prod outage (due to missing DB index)",
      "missed deadline, due to taking on unnecessary scope",
      "we started ignoring red CI builds, because they're \"probably just flaky\"",
      "PM expected one thing, team built another"
    ]

    user = current_user || create_guest_user
    @conversation = Conversation.create!(user: user, category: :landing_page)

    SendMessageWorker.new.perform(@conversation.id, "**What fire did you put out recently?**\n#{params[:initial_message]}", user.id)

    if hardcoded_flow_messages.include?(params[:initial_message]).present?
      redirect_to conversation_path(@conversation, require_tos: true)
    else
      redirect_to conversation_path(@conversation)
    end
  end

  def show
    @conversation = Conversation.find(params[:id])

    if @conversation.user.present? && @conversation.user != current_user
      flash[:alert] = "You are not authorized to view this conversation."
      redirect_to root_path
    end
  end
end