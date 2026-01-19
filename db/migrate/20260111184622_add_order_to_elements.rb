class AddOrderToElements < ActiveRecord::Migration[7.1]
  def change
    add_column :elements, :order, :integer, default: 1, null: false
  end
end