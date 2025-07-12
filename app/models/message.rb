class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :user, optional: true

  validates :content, presence: true

  after_create :schedule_system_reply

  private

  def schedule_system_reply
    conversation.reply_to_user if user_generated?
  end
end