class AddDescriptionToExperiences < ActiveRecord::Migration[7.1]
  def change
    add_column :experiences, :description, :text
  end
end