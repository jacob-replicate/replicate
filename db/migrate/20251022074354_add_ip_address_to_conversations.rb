class AddIpAddressToConversations < ActiveRecord::Migration[7.1]
  def change
    add_column :conversations, :ip_address, :string
  end
end