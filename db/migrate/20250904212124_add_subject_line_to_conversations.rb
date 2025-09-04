class AddSubjectLineToConversations < ActiveRecord::Migration[7.1]
  def change
    add_column :conversations, :subject_line, :text
  end
end