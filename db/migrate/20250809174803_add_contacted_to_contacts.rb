class AddContactedToContacts < ActiveRecord::Migration[7.1]
  def change
    add_column :contacts, :contacted, :boolean, default: false, null: false
  end
end