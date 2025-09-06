class ConversationMailer < ApplicationMailer
  default 'X-TM-MessageType' => 'transactional'

  def drive(conversation)
    message_id = "<conversation-#{conversation.id}@replicate.info>"
    headers['Message-ID'] = message_id # TODO: This needs to be unique?
    headers['References']  = conversation.id # TODO: Does this need to reference the previous message? Process the webhook for the user's message first?
    headers['List-Unsubscribe'] = "https://replicate.info/members/#{conversation.recipient_id}/unsubscribe"

    subject = conversation.recipient.conversations.count == 1 ? "[SEV-1 Training] #{conversation.subject_line}" : conversation.subject_line

    mail(
      to: conversation.recipient.email,
      from: '"Replicate Loop" <loop@mail.replicate.info>',
      reply_to: "loop+#{conversation.id}@mail.replicate.info",
      subject: subject,
      message_stream: 'outbound',
      content_type: 'text/html',
      body: conversation.latest_system_message
    )
  end
end