class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users, id: :uuid do |t|
      t.text :provider
      t.text :uid
      t.text :email
      t.text :name
      t.text :avatar_url

      t.timestamps
    end

    add_index :users, [:provider, :uid], unique: true
  end
end