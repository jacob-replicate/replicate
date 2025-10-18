class Message < ApplicationRecord
  belongs_to :conversation

  validates :content, presence: true

  after_create :deliver_user_message_to_web
  after_create :schedule_system_reply
  after_create :generate_email_message_id_header

  scope :system, -> { where(user_generated: false) }
  scope :user, -> { where(user_generated: true) }

  def plain_text_content
    ActionView::Base.full_sanitizer.sanitize(content).gsub(/\s*\-\s*Unsubscribe\z/, "")
  end

  private

  def generate_email_message_id_header
    return unless conversation.email? && !(user_generated)
    update!(email_message_id_header: "<message-#{id}@mail.replicate.info>")
  end

  def deliver_user_message_to_web
    return unless conversation.web? && user_generated && !suggested
    generator = MessageGenerators::Coaching.new(conversation)
    generator.broadcast_to_web(message: content, user_generated: true)
    generator.broadcast_to_web(type: "done", user_generated: true)
  end

  def schedule_system_reply
    return unless user_generated
    ConversationDriverWorker.perform_async(conversation_id)
  end
end