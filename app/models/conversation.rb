class Conversation < ApplicationRecord
  belongs_to :user, optional: true
  has_many :messages, dependent: :destroy

  def message_history
    messages.order(created_at: :asc).map do |message|
      {
        role: message.user ? "user" : "assistant",
        content: message.content
      }
    end
  end

  def reply_prompt_code
    if category == "landing_page"
      if messages.where(user: user).count == 1
        "landing_page_incident"
      else
        "respond_to_user_message"
      end
    else
      "respond_to_user_message"
    end
  end
end