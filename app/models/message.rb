class Message < ApplicationRecord
  belongs_to :conversation

  validates :content, presence: true

  after_create :schedule_system_reply

  scope :system, -> { where(user_generated: false) }
  scope :user, -> { where(user_generated: true) }

  def plain_text_content
    ActionView::Base.full_sanitizer.sanitize(content).gsub(/\s*\-\s*Unsubscribe\z/, "")
  end

  private

  def schedule_system_reply
    return unless user_generated

    min_sequence = conversation.next_message_sequence

    unless suggested
      generator = MessageGenerators::Incident.new(conversation)
      generator.broadcast_to_web(message: content, user_generated: true)
      generator.broadcast_to_web(type: "done", user_generated: true)
      min_sequence += 2
    end

    ConversationDriverWorker.perform_async(conversation_id, min_sequence)
  end
end