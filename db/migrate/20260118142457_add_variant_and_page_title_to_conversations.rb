class AddVariantAndPageTitleToConversations < ActiveRecord::Migration[7.1]
  def change
    add_column :conversations, :variant, :string
    add_column :conversations, :page_title, :string
  end
end
