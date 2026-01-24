class ElementsController < ApplicationController
  def show
    @element = Element.includes(:conversation).find(params[:id])

    conversation = @element.conversation || @element.create_conversation!
    @element.touch
    conversation.touch

    redirect_to conversation_path(conversation)
  end
end