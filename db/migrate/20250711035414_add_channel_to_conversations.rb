class AddChannelToConversations < ActiveRecord::Migration[7.1]
  def change
    add_column :conversations, :channel, :string
  end
end