class CreateTopics < ActiveRecord::Migration[7.1]
  def change
    create_table :topics, id: :uuid do |t|
      t.text :name
      t.text :description
      t.text :generation_intent

      t.timestamps
    end
  end
end
