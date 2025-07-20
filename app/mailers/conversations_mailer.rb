class ConversationsMailer < ApplicationMailer
  def drive
    mail(
      subject: 'Hello from Postmark',
      to: 'support@replicate.info',
      from: 'support@replicate.info',
      html_body: '<strong>Hello</strong> dear Postmark user.',
      track_opens: 'true',
      message_stream: 'outbound')
  end
end