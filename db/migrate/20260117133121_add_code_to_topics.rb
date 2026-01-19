class AddCodeToTopics < ActiveRecord::Migration[7.1]
  def change
    add_column :topics, :code, :text
  end
end