class CreateMessageComponents < ActiveRecord::Migration[7.1]
  def change
    create_table :message_components, id: :uuid do |t|
      t.references :message, type: :uuid, null: false, foreign_key: true
      t.integer :position, null: false
      t.jsonb :data, null: false, default: {}

      t.timestamps
    end

    add_index :message_components, [:message_id, :position], unique: true
  end
end