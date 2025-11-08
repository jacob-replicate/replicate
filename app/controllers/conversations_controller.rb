class ConversationsController < ApplicationController
  def show
    @conversation = Conversation.where(channel: "web").find_by(id: params[:id])

    if @conversation.blank? && params[:sharing_code].present?
      @conversation = Conversation.fork(params[:sharing_code])
      @conversation.update(ip_address: request.remote_ip)
    end

    @title = @conversation.context["title"] || "replicate.info"
  end

  def update
    @conversation = Conversation.find(params[:id])
    # @conversation.update(fingerprint: params[:fizzbuzz])
  end

  def destroy
    @conversation = Conversation.find(params[:id])
    @conversation.destroy
    redirect_to "/growth"
  end
end