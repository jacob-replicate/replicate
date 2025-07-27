class SubscribersController < ApplicationController
  def create
    @subscriber = Subscriber.new(subscriber_params.merge(subscribed: true))
    @subscriber.save
  end

  def edit
    @subscriber = Subscriber.find(params[:id])
  end

  def destroy
    @subscriber = Subscriber.find(params[:id])
    @subscriber.destroy
  end

  private

  def subscriber_params
    params.require(:subscriber).permit(:email)
  end
end