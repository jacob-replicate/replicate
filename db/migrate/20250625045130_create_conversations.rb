class CreateConversations < ActiveRecord::Migration[7.1]
  def change
    create_table :conversations, id: :uuid do |t|
      t.string :recipient_id
      t.string :recipient_type

      t.timestamps
    end
  end
end