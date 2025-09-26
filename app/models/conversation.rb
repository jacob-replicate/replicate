class Conversation < ApplicationRecord
  belongs_to :recipient, polymorphic: true, optional: true
  has_many :messages, dependent: :destroy

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
    fake_names = ["Taylor Morales", "Casey Patel", "Alex Shaw"]
    fake_name_conditions = fake_names.map { |name| "content LIKE '%#{name}%'" }.join(" OR ")

    real_user_message_count = messages.user.count
    real_system_message_count = messages.system.count

    (real_user_message_count * 2) + (real_system_message_count * 6)
  end
end