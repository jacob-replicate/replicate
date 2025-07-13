class StaticController < ApplicationController
  def index
  end

  def terms
    redirect_to "https://docs.google.com/document/d/1C0zn0671Wg4czBThwsL6bT7Db3btpAsfJepTAMclnuU", allow_other_host: true
  end

  def privacy
    redirect_to "https://docs.google.com/document/d/1SZEi3VcuNtLCLhg44WaSDuNTfndmT9BqdF5-djxKEeM", allow_other_host: true
  end

  def pricing
  end

  def demo
    return start_conversation(
      context: {
        conversation_type: :landing_demo,
        initial_message: "**What went sideways in production recently?**\n\ndeploy broke SSO authentication in prod (forgot to feature flag new project)"
      },
      force_tos: true
    )
  end

  def coaching
    return start_conversation(
      context: { conversation_type: :coaching },
      force_tos: true
    )
  end

  def security
  end

  def how_it_works
  end

  def knowledge_gaps
    redirect_to "https://docs.google.com/document/d/1YSmtsZYZ6qJrTOv4raqOUcU2Q1YvrVTzlab9QjUFT50/edit", allow_other_host: true
  end
end