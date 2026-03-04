class StaticController < ApplicationController
  def index
  end

  def terms
    @title = "Terms of Service"
  end

  def billing
    @title = "Billing"
  end
end