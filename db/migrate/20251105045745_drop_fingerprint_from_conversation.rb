class DropFingerprintFromConversation < ActiveRecord::Migration[7.1]
  def change
    remove_column :conversations, :fingerprint
  end
end