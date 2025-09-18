class ChangeConversationIdColumnTypeOnMessages < ActiveRecord::Migration[7.1]
  def change
    change_column :messages, :conversation_id, :uuid, using: 'conversation_id::uuid'
  end
end