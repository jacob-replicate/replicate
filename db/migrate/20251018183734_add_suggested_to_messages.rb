class AddSuggestedToMessages < ActiveRecord::Migration[7.1]
  def change
    add_column :messages, :suggested, :boolean, default: false
  end
end