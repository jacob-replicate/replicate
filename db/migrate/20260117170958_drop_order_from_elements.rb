class DropOrderFromElements < ActiveRecord::Migration[7.1]
  def change
    remove_column :elements, :order
  end
end