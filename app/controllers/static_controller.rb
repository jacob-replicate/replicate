class StaticController < ApplicationController
  def index
  end

  def terms
  end

  def privacy
  end

  def billing
    @title = "Billing"
  end

  def demo
    return start_conversation(
      context: {
        conversation_type: :landing_demo,
        engineer_name: "Alex Shaw",
        first_name: "Alex",
        incident: INCIDENTS.sample
      },
      force_tos: true
    )
  end

  def coaching
    name = ["Alex Shaw", "Taylor Morales", "Casey Patel"].sample
    first_name = name.split.first

    return start_conversation(
      context: {
        conversation_type: :coaching,
        engineer_name: name,
        first_name: first_name,
        incident: INCIDENTS.sample
      },
      force_tos: true
    )
  end

  def security
    @title = "Security"
  end

  def knowledge_gaps
    redirect_to "https://docs.google.com/document/d/1YSmtsZYZ6qJrTOv4raqOUcU2Q1YvrVTzlab9QjUFT50/edit", allow_other_host: true
  end
end