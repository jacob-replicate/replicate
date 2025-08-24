class CreatePostmarkWebhooks < ActiveRecord::Migration[7.1]
  def change
    create_table :postmark_webhooks, id: :uuid do |t|
      t.string :webhook_type
      t.json :content
      t.uuid :conversation_id
      t.datetime :processed_at

      t.timestamps
    end
  end
end