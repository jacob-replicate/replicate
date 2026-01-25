class AddStateToExperiences < ActiveRecord::Migration[7.1]
  def change
    add_column :experiences, :state, :text
  end
end