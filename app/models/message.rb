class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :user, optional: true

  validates :content, presence: true

  after_create :deliver_user_message_to_web
  after_create :schedule_system_reply

  scope :system, -> { where(user_generated: false) }
  scope :user, -> { where(user_generated: true) }

  private

  def demo_message?
    conversation.context["conversation_type"] == "landing_demo"
  end

  def deliver_user_message_to_web
    return unless conversation.web? && user_generated && !demo_message?
    sequence = conversation.next_message_sequence - 2
    ConversationChannel.broadcast_to(conversation, { message: content, user_generated: user_generated, sequence: sequence })
    ConversationChannel.broadcast_to(conversation, { type: "done", sequence: sequence + 1 })
  end

  def schedule_system_reply
    return unless user_generated && !demo_message?
    ConversationDriverWorker.perform_async(conversation_id)
  end
end