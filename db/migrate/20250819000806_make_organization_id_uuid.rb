class MakeOrganizationIdUuid < ActiveRecord::Migration[7.1]
  def up
    remove_foreign_key :members, name: "fk_rails_52498fc759"

    change_column_default :organizations, :id, nil

    # Convert the primary key in place. Every row gets a fresh UUID.
    # (This is safe because we have no production refs yet.)
    execute <<~SQL
    ALTER TABLE organizations
      ALTER COLUMN id DROP DEFAULT,
      ALTER COLUMN id TYPE uuid USING gen_random_uuid(),
      ALTER COLUMN id SET DEFAULT gen_random_uuid();
    SQL

    execute "DROP SEQUENCE IF EXISTS organizations_id_seq;"
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "organizations.id was converted to UUID"
  end
end