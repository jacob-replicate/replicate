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
    return redirect_to_demo_conversation(initial_message: "deploy broke SSO authentication in prod (forgot to feature flag new project)", force_tos: true)
  end

  def security
    redirect_to "https://docs.google.com/document/d/1rqwWku--SR-HS86kNIdHMhG-GRfn9QCCxcAARYOYLpA", allow_other_host: true
  end

  def how_it_works
  end

  def knowledge_gaps
    redirect_to "https://docs.google.com/document/d/1YSmtsZYZ6qJrTOv4raqOUcU2Q1YvrVTzlab9QjUFT50/edit", allow_other_host: true
  end
end