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
    redirect_to "https://docs.google.com/document/d/15y7929kcBgyIA19VQOQkdSbIXYb2jXmhrwKRGtw59Tk", allow_other_host: true
  end

  def security
    redirect_to "https://docs.google.com/document/d/1rqwWku--SR-HS86kNIdHMhG-GRfn9QCCxcAARYOYLpA", allow_other_host: true
  end

  def features
    redirect_to "https://docs.google.com/document/d/1wvh5NP537XPxR9aYDnADGVbqcUkWOUdFCJpCSvSyPRA", allow_other_host: true
  end
end