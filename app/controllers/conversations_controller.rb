class ConversationsController < ApplicationController
  def show
    @title = "replicate.info"
    @conversation = Conversation.where(channel: "web").find(params[:id])
  end
end