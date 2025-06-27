class CreateMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :messages, id: :uuid do |t|
      t.text :content
      t.string :conversation_id
      t.string :user_id

      t.timestamps
    end

    add_index :messages, :conversation_id
    add_index :messages, :user_id
  end
end