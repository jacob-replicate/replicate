class AddSequenceCountToConversation < ActiveRecord::Migration[7.1]
  def change
    add_column :conversations, :sequence_count, :integer, default: 0, null: false
    remove_column :messages, :sequence_count
  end
end