class Conversation < ApplicationRecord
  belongs_to :recipient, polymorphic: true
  has_many :messages, dependent: :destroy

  def web?
    category == "landing_page"
  end

  def latest_user_message
    messages.where(recipient: recipient).order(created_at: :desc).first&.content.to_s
  end

  def message_history
    messages.order(created_at: :asc).map do |message|
      {
        role: (message.user_generated ? "user" : "assistant"),
        content: message.content
      }
    end
  end

  def reply_prompt_code
    email_regex = /\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b/i
    last_message = latest_user_message

    if last_message.match?(email_regex)
      # return "respond_to_user_email"
    end

    if category == "landing_page"
      if messages.count == 1
        "landing_page_incident"
      elsif last_message == "1"
        "example_report"
      else
        "respond_to_user_message"
      end
    else
      "respond_to_user_message"
    end
  end
end