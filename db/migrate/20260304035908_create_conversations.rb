class CreateConversations < ActiveRecord::Migration[7.1]
  def change
    create_table :conversations, id: :uuid do |t|
      t.text :session_id
      t.text :topic
      t.uuid :template_id
      t.boolean :template, default: false
      t.uuid :last_read_message_id

      t.timestamps
    end

    add_index :conversations, :session_id
    add_index :conversations, :topic
    add_index :conversations, :template_id
    add_index :conversations, :template
    add_foreign_key :conversations, :conversations, column: :template_id
  end
end