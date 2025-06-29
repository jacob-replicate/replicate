class StaticController < ApplicationController
  def index
  end

  def terms
    redirect_to "https://docs.google.com/document/d/1C0zn0671Wg4czBThwsL6bT7Db3btpAsfJepTAMclnuU", allow_other_host: true
  end

  def privacy
    redirect_to "https://docs.google.com/document/d/1SZEi3VcuNtLCLhg44WaSDuNTfndmT9BqdF5-djxKEeM", allow_other_host: true
  end
end