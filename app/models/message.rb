class Message < ApplicationRecord
  belongs_to :conversation
  has_many :components, class_name: "MessageComponent", dependent: :destroy

  default_scope { order(:sequence) }

  scope :system_messages, -> { where(is_system: true) }
  scope :user_messages, -> { where(is_system: false) }
end