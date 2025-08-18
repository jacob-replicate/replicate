class AddEmailBouncedToMembers < ActiveRecord::Migration[7.1]
  def change
    add_column :members, :email_bounced, :boolean, default: false, null: false
  end
end