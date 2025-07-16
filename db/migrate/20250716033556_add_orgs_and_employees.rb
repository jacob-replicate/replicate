class AddOrgsAndEmployees < ActiveRecord::Migration[7.1]
  def change
    create_table :organizations do |t|
      t.string :name

      t.timestamps
    end

    create_table :employees do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :name
      t.string :email, null: false
      t.string :role, null: false
      t.boolean :should_receive_emails, null: false, default: true

      t.timestamps
    end

    add_index :employees, [:organization_id, :email], unique: true
  end
end