class RenameEmployeesToMembers < ActiveRecord::Migration[7.1]
  def change
    rename_table :employees, :members
  end
end