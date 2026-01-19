class RemoveContextFromConversations < ActiveRecord::Migration[7.1]
  def change
    remove_column :conversations, :context, :jsonb
  end
end