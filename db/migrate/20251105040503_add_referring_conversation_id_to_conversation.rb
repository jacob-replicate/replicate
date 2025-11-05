class AddReferringConversationIdToConversation < ActiveRecord::Migration[7.1]
  def change
    add_column :conversations, :referring_conversation_id, :uuid
    add_index :conversations, :referring_conversation_id
  end
end