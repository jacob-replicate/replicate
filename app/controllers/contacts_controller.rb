class ContactsController < ApplicationController
  def unsubscribe
    @contact = Contact.find_by(id: params[:id])

    if @contact.present?
      @contact.update(unsubscribed: true)
    else
      redirect_to root_path
    end
  end
end