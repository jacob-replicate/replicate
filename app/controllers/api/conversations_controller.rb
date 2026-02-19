# frozen_string_literal: true

module Api
  class ConversationsController < BaseController
    before_action :find_conversation, only: %i[show update]

    # GET /api/conversations
    # Returns all conversations for the current owner (without messages)
    def index
      conversations = conversations_scope
        .order(updated_at: :desc)
        .select(:id, :uuid, :name, :section, :unread_count, :is_muted, :is_private, :updated_at)

      render json: conversations.map { |c| conversation_json(c) }
    end

    # GET /api/conversations/:uuid
    # Returns a single conversation with its messages
    def show
      render json: conversation_json(@conversation, include_messages: true)
    end

    # PATCH /api/conversations/:uuid
    # Update conversation (mark as read, mute, etc.)
    def update
      if params[:last_read_message_id].present?
        @conversation.mark_as_read_up_to(params[:last_read_message_id])
      end

      if params.key?(:muted)
        @conversation.update!(is_muted: params[:muted])
      end

      render json: conversation_json(@conversation)
    end

    private

    def find_conversation
      @conversation = conversations_scope.find_by(uuid: params[:id])
      render_not_found unless @conversation
    end

    def conversation_json(conversation, include_messages: false)
      json = {
        uuid: conversation.uuid,
        id: conversation.uuid, # For backward compatibility
        name: conversation.name,
        section: conversation.section,
        unreadCount: conversation.unread_count,
        isMuted: conversation.is_muted,
        isPrivate: conversation.is_private,
        updatedAt: conversation.updated_at.iso8601,
      }

      if include_messages
        json[:messages] = conversation.messages.order(:sequence).map { |m| message_json(m) }
        json[:messagesLoading] = 'complete'
      end

      json
    end

    def message_json(message)
      {
        id: message.id,
        content: message.content,
        author: {
          name: message.author_name,
          avatar: message.author_avatar,
        },
        timestamp: message.created_at.iso8601,
        sequence: message.sequence,
        components: message.components,
        reactions: message.reactions,
      }
    end
  end
end