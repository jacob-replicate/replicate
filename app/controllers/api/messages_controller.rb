# frozen_string_literal: true

module Api
  class MessagesController < BaseController
    before_action :find_conversation

    # POST /api/conversations/:conversation_uuid/messages
    def create
      message = @conversation.messages.build(
        content: params[:content],
        author_name: current_user&.name || 'You',
        author_avatar: current_user&.avatar_url,
        user_generated: true
      )

      if message.save
        # Trigger bot response worker if needed
        # ConversationDriverWorker.perform_async(@conversation.id, message.sequence)

        render json: message_json(message), status: :created
      else
        render_error(message.errors.full_messages.join(', '))
      end
    end

    private

    def find_conversation
      @conversation = conversations_scope.find_by(uuid: params[:conversation_uuid])
      render_not_found unless @conversation
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