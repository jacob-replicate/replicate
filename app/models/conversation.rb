class Conversation < ApplicationRecord
  belongs_to :template_conversation, class_name: "Conversation", foreign_key: :template_id, optional: true
  has_many :forked_conversations, class_name: "Conversation", foreign_key: :template_id, dependent: :nullify
  has_many :messages, dependent: :destroy

  scope :templates, -> { where(template: true) }
end