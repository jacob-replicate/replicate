class SendColdEmailWorker
  include Sidekiq::Worker

  sidekiq_options retry: false, lock: :until_executed

  def perform(contact_id, inbox, variant)
    inbox   = inbox.transform_keys(&:to_sym)
    contact = Contact.us.enriched.find_by(id: contact_id)
    return if contact.blank? || contact.contacted? || contact.email.blank? || contact.email == "email_not_unlocked@domain.com"

    now_et = Time.current.in_time_zone("America/New_York")
    unless now_et.on_weekday? && now_et.hour.between?(9, 17)
      contact.update_columns(email_queued_at: nil)
      return
    end

    from_email    = inbox["email"]
    from_name     = inbox["from_name"]
    json_key_path = Rails.root + "try-replicate-gmail.json"

    client = Google::Apis::GmailV1::GmailService.new
    authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: StringIO.new(File.read(json_key_path)),
      scope: scopes
    )
    authorizer.update!(sub: from_email)
    client.authorization = authorizer.fetch_access_token!["access_token"]

    rfc822 = [
      "To: #{contact.email}",
      "From: #{from_name} <#{from_email}>",
      "Reply-To: #{from_email}",
      "Date: #{Time.now.utc.rfc2822}",
      "Subject: #{variant["subject"]}",
      "MIME-Version: 1.0",
      "Content-Type: text/html; charset=UTF-8",
      "List-Unsubscribe: <https://replicate.info/contacts/#{contact.id}/unsubscribe>, <mailto:#{from_email}?subject=unsubscribe>",
      "List-Unsubscribe-Post: List-Unsubscribe=One-Click",
      "",
      variant["body_html"]
    ].join("\r\n")

    client.send_user_message("me", Google::Apis::GmailV1::Message.new(raw: rfc822))
    contact.update_columns(contacted: true)
  end

  def scopes
    [
      "https://mail.google.com",
      "https://www.googleapis.com/auth/gmail.compose",
      "https://www.googleapis.com/auth/gmail.modify",
      "https://www.googleapis.com/auth/gmail.readonly"
    ]
  end
end