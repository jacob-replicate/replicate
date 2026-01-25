class AddStateToTopics < ActiveRecord::Migration[7.1]
  def change
    add_column :topics, :state, :text
  end
end