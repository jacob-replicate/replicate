class AddContextToConversations < ActiveRecord::Migration[7.1]
  def change
    add_column :conversations, :context, :jsonb, null: false, default: {}
  end
end