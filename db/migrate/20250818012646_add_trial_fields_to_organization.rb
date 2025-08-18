class AddTrialFieldsToOrganization < ActiveRecord::Migration[7.1]
  def change
    add_column :organizations, :access_end_date, :datetime
    add_column :organizations, :flagged, :boolean, default: false
    add_column :organizations, :flagged_reason, :text
    remove_column :members, :should_receive_emails
  end
end