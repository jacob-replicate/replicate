class Message < ApplicationRecord
  belongs_to :conversation

  validates :content, presence: true

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

  def schedule_system_reply
    return unless user_generated

    min_sequence = conversation.next_message_sequence

    if conversation.web? && !suggested
      generator = MessageGenerators::Coaching.new(conversation)
      generator.broadcast_to_web(message: content, user_generated: true)
      generator.broadcast_to_web(type: "done", user_generated: true)
      min_sequence += 2
    end

    ConversationDriverWorker.perform_async(conversation_id, min_sequence)
  end
end