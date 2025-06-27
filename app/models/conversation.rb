class Conversation < ApplicationRecord
  belongs_to :user, optional: true
  has_many :messages, dependent: :destroy

  def message_history
    messages.order(created_at: :asc).map do |message|
      {
        role: message.user ? "user" : "assistant",
        content: message.content
      }
    end
  end
end