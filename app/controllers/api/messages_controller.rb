# frozen_string_literal: true

module Api
  class MessagesController < ApplicationController
    skip_before_action :verify_authenticity_token
    before_action :find_conversation

    def create
      message = nil

      @conversation.with_lock do
        next_sequence = (@conversation.messages.maximum(:sequence) || 0) + 1

        message = @conversation.messages.build(
          sequence: next_sequence,
          author_name: 'You',
          author_avatar: "user-profile.jpg",
          is_system: false
        )

        message.save!
        message.components.create!(position: 0, data: { type: 'text', content: params[:content] })
      end

      render json: message_json(message), status: :created
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: e.message }, status: :unprocessable_entity
    end

    private

    def find_conversation
      @conversation = current_session_conversations.find(params[:conversation_id])
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