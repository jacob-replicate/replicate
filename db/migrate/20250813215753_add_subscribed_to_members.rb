class AddSubscribedToMembers < ActiveRecord::Migration[7.1]
  def change
    add_column :members, :subscribed, :boolean, default: true, null: false
  end
end