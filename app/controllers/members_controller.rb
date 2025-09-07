class MembersController < ApplicationController
  def unsubscribe
    @member = Member.find_by(id: params[:id])

    if @member.blank?
      redirect_to root_path
    end
  end

  def unsubscribe_confirm
    @member = Member.find_by(id: params[:id])

    if @member.present?
      @member.update(subscribed: false)
    else
      redirect_to root_path
    end
  end

  def resubscribe
    @member = Member.find_by(id: params[:id])

    if @member.blank?
      redirect_to root_path
    end
  end

  def resubscribe_confirm
    @member = Member.find_by(id: params[:id])

    if @member.present?
      @member.update(subscribed: true)
    else
      redirect_to root_path
    end
  end
end