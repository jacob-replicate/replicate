class CreateMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :messages, id: :uuid do |t|
      t.references :conversation, type: :uuid, null: false, foreign_key: true
      t.integer :sequence, null: false
      t.string :author_name
      t.string :author_avatar
      t.boolean :is_system, default: false

      t.timestamps
    end

    add_index :messages, [:conversation_id, :sequence], unique: true
  end
end