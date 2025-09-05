class DropSubscribersTable < ActiveRecord::Migration[7.1]
  def change
    drop_table :subscribers
  end
end