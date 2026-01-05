class CreateExperiences < ActiveRecord::Migration[7.1]
  def change
    create_table :experiences, id: :uuid do |t|
      t.boolean :template
      t.text :code
      t.text :name
      t.text :session_id

      t.timestamps
    end
  end
end