class ChangeMemberOrgIdToUuid < ActiveRecord::Migration[7.1]
  def change
    change_column :members, :organization_id, :string
  end
end