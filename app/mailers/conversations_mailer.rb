class ConversationsMailer < ApplicationMailer
  def drive
    mail(
      subject: 'Hello from Postmark',
      to: 'jacob@replicate.info',
      from: 'jacob@replicate.info',
      html_body: '<strong>Hello</strong> dear Postmark user.',
      track_opens: 'true',
      message_stream: 'outbound')
  end
end