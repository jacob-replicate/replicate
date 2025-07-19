class AddAdditionalFieldsToContact < ActiveRecord::Migration[7.1]
  def change
    add_column :contacts, :source, :text
    add_column :contacts, :external_id, :text
    add_column :contacts, :score, :integer, default: 0
    add_column :contacts, :score_reason, :text
    add_column :contacts, :metadata, :jsonb, default: {}
    drop_table :metadata
  end
end