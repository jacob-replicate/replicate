class CreateConversations < ActiveRecord::Migration[7.1]
  def change
    create_table :conversations, id: :uuid do |t|
      t.references :recipient, polymorphic: true, index: true, type: :uuid
      t.timestamps
    end
  end
end