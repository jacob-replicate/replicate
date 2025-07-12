class Conversation < ApplicationRecord
  belongs_to :recipient, polymorphic: true
  has_many :messages, dependent: :destroy

  def web?
    channel == "web"
  end

  def latest_user_message
    messages.where(user_generated: true).order(created_at: :desc).first&.content.to_s
  end

  def message_history
    messages.order(created_at: :asc).map do |message|
      {
        role: (message.user_generated ? "user" : "assistant"),
        content: message.content
      }
    end
  end

  def next_prompt_code
    messages.count == 0 ? initial_prompt_code : reply_prompt_code
  end

  def reply_to_user
    message_template = "MessageTemplates::#{context[:conversation_type]}".constantize.new(self)
    # TODO: Create it
    # TODO: Deliver it
  end

  def initial_prompt_code
    conversation_type = context["conversation_type"]

    if conversation_type == "coaching"
      "coaching_intro"
    elsif conversation_type == "manager_report"
      "manager_report_intro"
    else
      "user_intro"
    end
  end

  def reply_prompt_code
    last_message = latest_user_message

    conversation_type = context["conversation_type"]

    if conversation_type == "landing_page"
      if messages.count == 1
        "landing_page_incident"
      elsif last_message == "1"
        "example_report"
      else
        "respond_to_demo_thread"
      end
    elsif conversation_type == "coaching"
      "coaching_reply"
    elsif conversation_type == "manager_report"
      "respond_to_manager_report_thread"
    else
      "respond_to_user_thread"
    end
  end
end