class AddSharingCodeToConversation < ActiveRecord::Migration[7.1]
  def change
    add_column :conversations, :sharing_code, :string
    add_index :conversations, :sharing_code
  end
end