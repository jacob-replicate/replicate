class ConversationMailer < ApplicationMailer
  default 'X-TM-MessageType' => 'transactional'

  def drive(conversation)
    message = conversation.latest_system_message

    prior_message_ids = Message.where(conversation_id: conversation.id).where.not(id: message.id).order(:created_at).pluck(:email_message_id_header)
    references_history = Message.where(conversation_id: conversation.id).where.not(id: message.id).order(:created_at).pluck(:email_message_id_header)
    headers['Message-ID'] = message.email_message_id_header
    headers['In-Reply-To'] = prior_message_ids.last
    headers['References']  = prior_message_ids.join(" ")
    headers['List-Unsubscribe'] = "https://replicate.info/members/#{conversation.recipient_id}/unsubscribe"

    subject = conversation.recipient.conversations.count == 1 ? "[SEV-1 Training] #{conversation.subject_line}" : conversation.subject_line

    mail(
      to: conversation.recipient.email,
      from: 'Replicate Loop <loop@mail.replicate.info>',
      reply_to: "loop+#{conversation.id}@mail.replicate.info",
      subject: subject,
      message_stream: 'outbound',
      content_type: 'text/html',
      body: message.content
    )
  end
end