class MakeMemberIdAUuid < ActiveRecord::Migration[7.1]
  def up
    change_column_default :members, :id, nil

    # Convert the primary key in place. Every row gets a fresh UUID.
    # (This is safe because we have no production refs yet.)
    execute <<~SQL
    ALTER TABLE members
      ALTER COLUMN id DROP DEFAULT,
      ALTER COLUMN id TYPE uuid USING gen_random_uuid(),
      ALTER COLUMN id SET DEFAULT gen_random_uuid();
    SQL

    execute "DROP SEQUENCE IF EXISTS members_id_seq;"
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "members.id was converted to UUID"
  end
end