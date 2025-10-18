class AddFingerprintToConversations < ActiveRecord::Migration[7.1]
  def change
    add_column :conversations, :fingerprint, :text
  end
end