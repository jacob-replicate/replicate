class AddUnsubscribedToContacts < ActiveRecord::Migration[7.1]
  def change
    add_column :contacts, :unsubscribed, :boolean, default: false, null: false
  end
end