class Conversation < ApplicationRecord
  belongs_to :recipient, polymorphic: true
  has_many :messages, dependent: :destroy

  def web?
    channel == "web"
  end

  def latest_user_message
    messages.where(user_generated: true).order(created_at: :desc).first&.content.to_s
  end

  def latest_author
    return nil if messages.empty?
    messages.order(:created_at).last&.user_generated ? :user : :assistant
  end

  def message_history
    messages.order(created_at: :asc).map do |message|
      {
        role: (message.user_generated ? "user" : "assistant"),
        content: message.content
      }
    end
  end
end