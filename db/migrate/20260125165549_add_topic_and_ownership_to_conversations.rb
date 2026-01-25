class AddTopicAndOwnershipToConversations < ActiveRecord::Migration[7.1]
  def change
    # Add topic reference (nullable - existing conversations may not have a topic)
    add_reference :conversations, :topic, null: true, foreign_key: true, type: :uuid

    # Polymorphic owner - can be a User (logged in) or session_id string (anonymous)
    add_column :conversations, :owner_type, :string
    add_column :conversations, :owner_id, :text
    add_index :conversations, [:owner_type, :owner_id]

    # Template conversations are the source of truth, forked for each user
    add_column :conversations, :template, :boolean, default: false, null: false

    # Metadata (moved from Experience)
    add_column :conversations, :name, :text
    add_column :conversations, :description, :text
    add_column :conversations, :code, :text
    add_column :conversations, :state, :text, default: 'pending'

    # Composite index for finding user's conversations by topic
    add_index :conversations, [:topic_id, :owner_type, :owner_id]
    add_index :conversations, [:topic_id, :code, :template], unique: true, where: "template = true"
  end
end