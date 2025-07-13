class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :user, optional: true

  validates :content, presence: true

  after_create :deliver_user_message_to_web
  after_create :schedule_system_reply

  private

  def deliver_user_message_to_web
    return unless conversation.web? && user_generated
    ConversationChannel.broadcast_to(conversation, { message: content, user_generated: user_generated })
    ConversationChannel.broadcast_to(conversation, { type: "done" })
  end

  def schedule_system_reply
    return unless conversation.web? && user_generated
    ConversationDriverWorker.perform_async(conversation_id)
  end
end