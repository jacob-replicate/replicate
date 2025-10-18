class Conversation < ApplicationRecord
  belongs_to :recipient, polymorphic: true, optional: true
  has_many :messages, dependent: :destroy

  def duration
    message_times = messages.pluck(:created_at).sort
    return nil if message_times.size < 2

    [1, ((message_times.last - message_times.first).to_i / 60.0).round].max
  end

  def email?
    channel == "email"
  end

  def web?
    channel == "web"
  end

  def latest_user_message
    messages.where(user_generated: true).order(created_at: :desc).first
  end

  def latest_system_message
    messages.where(user_generated: false).order(created_at: :desc).first
  end

  def latest_author
    return nil if messages.empty?
    messages.order(:created_at).last&.user_generated ? :user : :assistant
  end

  def message_history
    messages.order(created_at: :asc).map do |message|
      {
        role: (message.user_generated ? "user" : "assistant"),
        content: SanitizeAiContent.call(message.content)
      }
    end
  end

  def next_message_sequence
    sequence_count + 1
  end
end