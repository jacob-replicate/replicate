class ConversationsMailer < ApplicationMailer
  default 'X-TM-MessageType' => 'transactional'

  def drive(conversation)
    message_id = "<conversation-#{conversation.id}@replicate.info>"
    headers['Message-ID'] = message_id # TODO: This needs to be unique?
    headers['References']  = conversation.id # TODO: Does this need to reference the previous message? Process the webhook for the user's message first?
    headers['List-Unsubscribe'] = "https://replicate.info/members/#{conversation.recipient_id}/unsubscribe"

    mail(
      to: conversation.recipient.email,
      from: "loop@mail.replicate.info",
      from: '"Replicate Loop" <loop@mail.replicate.info>"',
      reply_to: "loop+#{conversation.id}@mail.replicate.info",
      subject: conversation.subject_line,
      message_stream: 'outbound',
      content_type: 'text/html',
      body: conversation.latest_system_message
    )
  end
end