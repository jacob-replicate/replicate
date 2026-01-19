class AddGenerationIntentToTables < ActiveRecord::Migration[7.1]
  def change
    add_column :experiences, :generation_intent, :text
    add_column :elements, :generation_intent, :text
  end
end