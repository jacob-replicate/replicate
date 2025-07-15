class ApplicationController < ActionController::Base
  def start_conversation(initial_message: nil, context: {}, force_tos: false)
    if context["engineer_name"].present?
      context["first_name"] = context["engineer_name"].split.first
    end

    @conversation = Conversation.create!(context: context, channel: :web)

    if force_tos || EXAMPLE_EMAILS.map { |email| email[:prompt] }.include?(initial_message).present?
      redirect_to conversation_path(@conversation, require_tos: true)
    else
      redirect_to conversation_path(@conversation)
    end
  end
end