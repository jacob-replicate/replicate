class CreateSessions < ActiveRecord::Migration[7.1]
  def change
    create_table :sessions, id: :uuid do |t|
      t.string :ip
      t.string :page
      t.string :referring_page
      t.integer :duration
      t.timestamps
    end
  end
end