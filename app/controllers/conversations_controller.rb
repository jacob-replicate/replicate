class ConversationsController < ApplicationController
  before_action :verify_admin

  def show
    @title = "replicate.info"
    @conversation = Conversation.where(channel: "web").find(params[:id])
  end

  def update
    @conversation = Conversation.find(params[:id])
    @conversation.update(fingerprint: params[:fingerprint])
  end

  def destroy
    @conversation = Conversation.find(params[:id])
    @conversation.destroy
    redirect_to "/growth"
  end
end