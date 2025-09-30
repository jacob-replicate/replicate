class AddUserAgentToSessions < ActiveRecord::Migration[7.1]
  def change
    add_column :sessions, :user_agent, :text
  end
end