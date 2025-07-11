class AddContextToConversations < ActiveRecord::Migration[7.1]
  def change
    add_column :conversations, :context, :string, null: false, default: "default"
  end
end