class CreateContacts < ActiveRecord::Migration[7.1]
  def change
    create_table :contacts, id: :uuid do |t|
      t.text :email
      t.text :location
      t.text :company_domain
      t.text :state

      t.timestamps
    end
  end
end
