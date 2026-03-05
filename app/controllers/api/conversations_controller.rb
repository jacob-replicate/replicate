# frozen_string_literal: true

module Api
  class ConversationsController < ApplicationController
    skip_before_action :verify_authenticity_token

    def index
      conversations = current_session_conversations.order(updated_at: :desc)
      render json: conversations.map { |c| conversation_json(c) }
    end

    def show
      conversation = current_session_conversations.find(params[:id])
      render json: conversation_json(conversation, include_messages: true)
    end

    def update
      conversation = current_session_conversations.find(params[:id])
      conversation.update!(conversation_params)
      render json: conversation_json(conversation)
    end

    private

    def conversation_params
      params.permit(:last_read_message_id)
    end

    def conversation_json(conversation, include_messages: false)
      json = {
        id: conversation.id,
        topic: conversation.topic,
        template: conversation.template,
        template_id: conversation.template_id,
        last_read_message_id: conversation.last_read_message_id,
        created_at: conversation.created_at.iso8601,
        updated_at: conversation.updated_at.iso8601,
      }

      if include_messages
        json[:messages] = conversation.messages.includes(:components).last(20).map { |m| message_json(m) }
      end

      json
    end

    def message_json(message)
      {
        id: message.id,
        sequence: message.sequence,
        author_name: message.author_name,
        author_avatar: message.author_avatar,
        is_system: message.is_system,
        created_at: message.created_at.iso8601,
        components: message.components.map { |c| c.data },
      }
    end
  end
end