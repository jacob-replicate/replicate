class AddEmailMessageIdHeaderToMessages < ActiveRecord::Migration[7.1]
  def change
    add_column :messages, :email_message_id_header, :text
  end
end