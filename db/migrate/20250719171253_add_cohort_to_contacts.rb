class AddCohortToContacts < ActiveRecord::Migration[7.1]
  def change
    add_column :contacts, :cohort, :text
  end
end