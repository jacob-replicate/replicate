class CreateSubscribers < ActiveRecord::Migration[7.1]
  def change
    create_table :subscribers, id: :uuid do |t|
      t.text :email
      t.boolean :subscribed

      t.timestamps
    end
  end
end
