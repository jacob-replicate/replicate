class RemoveContactedFromContacts < ActiveRecord::Migration[7.1]
  def change
    remove_column :contacts, :contacted
  end
end