class ContactsController < ApplicationController
  def unsubscribe
    @contact = Contact.find_by(id: params[:id])

    if @contact.blank?
      redirect_to root_path
    end
  end

  def unsubscribe_confirm
    @contact = Contact.find_by(id: params[:id])

    if @contact.present?
      @contact.update(unsubscribed: true)
    else
      redirect_to root_path
    end
  end

  def resubscribe
    @contact = Contact.find_by(id: params[:id])

    if @contact.blank?
      redirect_to root_path
    end
  end

  def resubscribe_confirm
    @contact = Contact.find_by(id: params[:id])

    if @contact.present?
      @contact.update(unsubscribed: false)
    else
      redirect_to root_path
    end
  end
end