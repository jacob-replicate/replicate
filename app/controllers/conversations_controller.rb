class ConversationsController < ApplicationController
  before_action :verify_admin, only: [:destroy]

  def show
    @conversation = Conversation.find_by(id: params[:id])

    if @conversation.blank? && params[:sharing_code].present?
      @conversation = Conversation.fork(params[:sharing_code])
      @conversation.update(ip_address: request.remote_ip)
    end

    if @conversation.blank?
      return redirect_to root_path
    end

    @title = [@conversation.page_title, "replicate.info"].reject(&:blank?).first
  end

  def update
    @conversation = Conversation.find(params[:id])
  end

  def destroy
    @conversation = Conversation.find(params[:id])
    @conversation.destroy
    redirect_to "/growth"
  end
end