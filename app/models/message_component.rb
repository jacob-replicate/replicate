class MessageComponent < ApplicationRecord
  belongs_to :message

  default_scope { order(:position) }

  TYPES = %w[text code diff multiple_choice].freeze

  def type
    data["type"]
  end

  def content
    data["content"]
  end
end