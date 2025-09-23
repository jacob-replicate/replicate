class CreateMissiveWebhooks < ActiveRecord::Migration[7.1]
  def change
    create_table :missive_webhooks, id: :uuid do |t|
      t.string :webhook_type
      t.json :content
      t.datetime :processed_at

      t.timestamps
    end
  end
end
