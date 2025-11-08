class Conversation < ApplicationRecord
  belongs_to :recipient, polymorphic: true, optional: true
  belongs_to :referring_conversation, class_name: "Conversation", optional: true
  before_validation :generate_sharing_code
  has_many :messages, dependent: :destroy

  def generate_sharing_code
    return if sharing_code.present?

    30.times do
      new_code = SecureRandom.alphanumeric(6).downcase
      if Conversation.where(sharing_code: new_code).empty?
        update(sharing_code: new_code)
        return
      end
    end
  end

  def send_admin_message(message)
    reload
    sequence = next_message_sequence
    broadcasting_context = { type: "element", sequence: sequence, user_generated: false, message: "#{AvatarService.jacob_avatar_row}<p>#{message}</p>" }
    ConversationChannel.broadcast_to(self, broadcasting_context)
    ConversationChannel.broadcast_to(self, { type: "done", sequence: sequence + 1 })
    update!(sequence_count: sequence + 1)
  end

  def difficulty
    context["difficulty"] || "senior"
  end

  def self.fork(sharing_code)
    original = Conversation.find_by!(sharing_code: sharing_code)
    forked = original.dup
    forked.recipient = nil
    forked.sharing_code = nil
    forked.created_at = Time.current
    forked.updated_at = Time.current
    forked.sequence_count = 0
    forked.referring_conversation = original
    forked.save!

    forked
  end

  def sharing_url
    Rails.env.development? ? "http://localhost:3000/incidents/#{sharing_code}" : "https://replicate.info/incidents/#{sharing_code}"
  end

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

  def turn
    messages.where(user_generated: true).count + 1
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
    messages.order(created_at: :asc).last(30).map do |message|
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