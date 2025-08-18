class AddEmailQueuedAtToContacts < ActiveRecord::Migration[7.1]
  def change
    add_column :contacts, :email_queued_at, :datetime, null: true, default: nil
  end
end