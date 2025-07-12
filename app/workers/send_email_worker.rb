class SendEmailWorker
  include Sidekiq::Worker

  def perform(message, conversation_id, auto_generated)
    conversation = Conversation.find_by(id: conversation_id)
    return unless conversation.present? && co

    if conversation.context == "cold_email"
      send_email_via_gmail(contact, subject, body)
    else
      # TODO: Send via Postmark
    end

    conversation.paid_emails.create!(
      subject: subject,
      content: body,
      message_id: message.id,
      user_generated: false,
      state: "delivered"
    )

    contact.update!(state: "contacted")
  end

  private

  def email_body_template
    <<~HTML
      Hi {{name}},<br><br>
      Just launched something after a rollback failed in prod again. It sends one short coaching puzzle every Monday — like a 5-minute drill to catch hidden risks early. All inbox, no dashboards.<br><br>
      Worth a peek?<br>
      —Jacob
    HTML
  end

  def send_email_via_gmail(contact, subject, body)
    sender_email = contact.assigned_inbox_email # e.g., "emily@try-replicate.info"

    s3 = Aws::S3::Resource.new(region: "us-east-2")
    s3_object = s3.bucket("lets-advance").object("google.json").get.body

    client = Google::Apis::GmailV1::GmailService.new
    scopes = [
      'https://mail.google.com',
      'https://www.googleapis.com/auth/gmail.compose',
      'https://www.googleapis.com/auth/gmail.modify'
    ]

    authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: s3_object,
      scope: scopes
    )
    authorizer.update!(sub: sender_email)
    client.authorization = authorizer.fetch_access_token!["access_token"]

    to = Rails.env.development? ? "jacob@jacobcomer.com" : contact.email_address

    raw = Base64.urlsafe_encode64(<<~EMAIL)
      To: #{to}
      Subject: #{subject}
      Content-Type: text/html; charset=UTF-8

      #{body}
    EMAIL

    message = Google::Apis::GmailV1::Message.new(raw: raw)
    client.send_user_message("me", message)
  end
end