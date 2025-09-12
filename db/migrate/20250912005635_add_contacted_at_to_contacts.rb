class AddContactedAtToContacts < ActiveRecord::Migration[7.1]
  def change
    add_column :contacts, :contacted_at, :datetime
  end
end