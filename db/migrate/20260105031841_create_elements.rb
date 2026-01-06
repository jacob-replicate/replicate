class CreateElements < ActiveRecord::Migration[7.1]
  def change
    create_table :elements, id: :uuid do |t|
      t.text :code
      t.jsonb :context
      t.uuid :experience_id
      t.uuid :element_id
      t.uuid :conversation_id

      t.timestamps
    end

    add_index :elements, :experience_id
    add_index :elements, :element_id
    add_index :elements, :conversation_id
  end
end