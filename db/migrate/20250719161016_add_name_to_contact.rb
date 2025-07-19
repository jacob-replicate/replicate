class AddNameToContact < ActiveRecord::Migration[7.1]
  def change
    add_column :contacts, :name, :text
  end
end