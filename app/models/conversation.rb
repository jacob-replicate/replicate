class Conversation < ApplicationRecord
  STATES = %w[pending populating populated].freeze

  belongs_to :recipient, polymorphic: true, optional: true
  belongs_to :referring_conversation, class_name: "Conversation", optional: true
  belongs_to :topic, optional: true
  belongs_to :owner, polymorphic: true, optional: true

  before_validation :generate_sharing_code
  has_many :messages, dependent: :destroy

  validates :state, inclusion: { in: STATES }, allow_nil: true

  scope :templates, -> { where(template: true) }
  scope :owned_by_session, ->(session_id) { where(owner_type: "Session", owner_id: session_id) }
  scope :owned_by_user, ->(user) { where(owner_type: "User", owner_id: user.id) }
  scope :pending, -> { where(state: "pending") }
  scope :populating, -> { where(state: "populating") }
  scope :populated, -> { where(state: "populated") }

  # State helpers
  def pending?
    state == "pending"
  end

  def populating?
    state == "populating"
  end

  def populated?
    state == "populated"
  end

  # Ownership helpers
  def owned_by_session?
    owner_type == "Session"
  end

  def owned_by_user?
    owner_type == "User"
  end

  def owned_by?(user_or_session_id)
    case user_or_session_id
    when User
      owner_type == "User" && owner_id == user_or_session_id.id.to_s
    when String
      owner_type == "Session" && owner_id == user_or_session_id
    else
      false
    end
  end

  # Transfer session-owned conversations to a user after login
  def self.transfer_session_to_user(session_id, user)
    where(owner_type: "Session", owner_id: session_id).find_each do |convo|
      convo.update!(owner_type: "User", owner_id: user.id.to_s)
    end
  end

  # Fork a template conversation for a specific owner
  def fork_for_owner!(owner_type:, owner_id:)
    raise "Can only fork template conversations" unless template?

    # Check if already forked for this owner
    existing = Conversation.find_by(
      topic_id: topic_id,
      code: code,
      template: false,
      owner_type: owner_type,
      owner_id: owner_id
    )
    return existing if existing

    forked = dup
    forked.template = false
    forked.owner_type = owner_type
    forked.owner_id = owner_id
    forked.sharing_code = nil
    forked.sequence_count = 0
    forked.referring_conversation = self
    forked.created_at = Time.current
    forked.updated_at = Time.current
    forked.save!

    forked
  end

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
    Rails.env.development? ? "http://localhost:3000/incidents/#{sharing_code}" : "https://invariant.training/incidents/#{sharing_code}"
  end

  def duration
    message_times = messages.pluck(:created_at).sort
    return nil if message_times.size < 2

    [1, ((message_times.last - message_times.first).to_i / 60.0).round].max
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
    last_message_count = variant == "incident" ? 30 : 6

    messages.order(created_at: :asc).last(last_message_count).map do |message|
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