class CreateMetadata < ActiveRecord::Migration[7.1]
  def change
    create_table :metadata, id: :uuid do |t|
      t.text :category
      t.text :identifier
      t.jsonb :content

      t.timestamps
    end
  end
end