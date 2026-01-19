class AddTopicIdToExperiences < ActiveRecord::Migration[7.1]
  def change
    add_column :experiences, :topic_id, :uuid
    add_index :experiences, :topic_id
  end
end