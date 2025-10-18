class AddSequenceCountToMessage < ActiveRecord::Migration[7.1]
  def change
    add_column :messages, :sequence_count, :integer, default: 0, null: false
  end
end