class ConversationsController < ApplicationController
  def show
    @title = "replicate.info"
    @conversation = Conversation.find(params[:id])
  end
end