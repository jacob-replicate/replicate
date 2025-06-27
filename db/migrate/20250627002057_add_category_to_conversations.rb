class AddCategoryToConversations < ActiveRecord::Migration[7.1]
  def change
    add_column :conversations, :category, :string
  end
end