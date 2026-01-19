class AddSortOrderToElements < ActiveRecord::Migration[7.1]
  def change
    add_column :elements, :sort_order, :integer
  end
end