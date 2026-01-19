class AddGenerationIntentToConversations < ActiveRecord::Migration[7.1]
  def change
    add_column :conversations, :generation_intent, :text
  end
end
