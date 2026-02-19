# frozen_string_literal: true

module Api
  class BaseController < ApplicationController
    # Skip CSRF for API requests (they use session cookies for auth)
    skip_before_action :verify_authenticity_token

    private

    # Returns the current owner (User or Session) for scoping queries
    # All API queries should use this to scope to the current user/session
    def current_owner
      if current_user
        current_user
      else
        # For session-based ownership, return a hash that can be used in queries
        { owner_type: 'Session', owner_id: session[:identifier] }
      end
    end

    # Scope for finding conversations owned by the current user or session
    def conversations_scope
      if current_user
        Conversation.where(owner: current_user)
      else
        Conversation.where(owner_type: 'Session', owner_id: session[:identifier])
      end
    end

    def render_error(message, status: :bad_request)
      render json: { error: message }, status: status
    end

    def render_not_found
      render json: { error: 'Not found' }, status: :not_found
    end
  end
end