class CreateBannedIps < ActiveRecord::Migration[7.1]
  def change
    create_table :banned_ips, id: :uuid do |t|
      t.string :address

      t.timestamps
    end
  end
end
