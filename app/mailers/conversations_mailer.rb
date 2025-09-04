class ConversationsMailer < ApplicationMailer
  default from: 'loop@mail.replicate.info'
  default 'X-TM-MessageType' => 'transactional'

  def drive(conversation)
    message_id = "<conversation-#{conversation.id}@replicate.info>"
    headers['Message-ID'] = message_id
    headers['In-Reply-To'] = message_id
    headers['References']  = message_id
    headers['List-Unsubscribe'] = nil

    raise

    mail(
      to: conversation.recipient.email,
      subject: conversation.subject_line,
      message_stream: 'outbound',
      content_type: 'text/html',
      body: conversation.latest_system_message.content
    )
  end
end