class ConversationMailer < ApplicationMailer
  def drive(conversation)
    message = conversation.latest_system_message
    prior_message_ids = conversation.messages.where.not(id: message.id).order(:created_at).pluck(:email_message_id_header).reject(&:blank?).uniq

    headers['Message-ID'] = message.email_message_id_header

    if prior_message_ids.any?
      headers['In-Reply-To'] = prior_message_ids.last
      headers['References']  = prior_message_ids.join(" ")
    end

    headers['List-Unsubscribe'] = "<https://replicate.info/members/#{conversation.recipient_id}/unsubscribe>"
    headers["List-Unsubscribe-Post"] = "List-Unsubscribe=One-Click"

    subject = conversation.recipient.conversations.count == 1 ? "[SEV-1 Training] #{conversation.subject_line}" : conversation.subject_line

    mail(
      from: 'Replicate Loop <loop@mail.replicate.info>',
      reply_to: "loop+#{conversation.id}@mail.replicate.info",
      subject: subject,
      to: conversation.recipient.email
    ) do |format|
      format.text { render plain: message.plain_text_content }
      format.html { render html: message.content.html_safe }
    end
  end
end