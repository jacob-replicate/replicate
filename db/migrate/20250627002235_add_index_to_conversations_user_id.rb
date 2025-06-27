class AddIndexToConversationsUserId < ActiveRecord::Migration[7.1]
  def change
    add_index :conversations, :user_id
  end
end