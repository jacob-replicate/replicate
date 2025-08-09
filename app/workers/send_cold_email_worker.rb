class SendColdEmailWorker
  include Sidekiq::Worker
  sidekiq_options queue: :outbound, retry: false, backtrace: false

  def perform(contact_id, subject, body_html, inbox)
    inbox   = inbox.transform_keys(&:to_sym)
    contact = Contact.find(contact_id)

    job_key = inbox[:job_key].to_s
    raise ArgumentError, "missing job_key" if job_key.empty?
    idem = Sidekiq.redis { |r| r.set("idem:cold_email:#{job_key}", 1, nx: true, ex: 172_800) }
    return unless idem

    from_email     = inbox[:email]
    from_name      = inbox[:from_name]
    json_key_path  = inbox[:json_key_path].to_s
    raise ArgumentError, "missing json_key_path" if json_key_path.empty?

    json_io = StringIO.new(File.read(json_key_path))

    client = Google::Apis::GmailV1::GmailService.new
    scopes = [
      "https://mail.google.com",
      "https://www.googleapis.com/auth/gmail.compose",
      "https://www.googleapis.com/auth/gmail.modify",
      "https://www.googleapis.com/auth/gmail.readonly"
    ]
    authorizer = Google::Auth::ServiceAccountCredentials.make_creds(json_key_io: json_io, scope: scopes)
    authorizer.update!(sub: from_email)
    client.authorization = authorizer.fetch_access_token!["access_token"]

    list_unsub_url  = "https://replicate.info/unsub/#{contact.uuid}"
    list_unsub_mail = "mailto:#{from_email}?subject=unsubscribe"

    from_header = from_name.to_s.strip.empty? ? from_email : "#{from_name} <#{from_email}>"
    rfc822 = [
      "To: #{contact.email}",
      "From: #{from_header}",
      "Subject: #{subject}",
      "MIME-Version: 1.0",
      "Content-Type: text/html; charset=UTF-8",
      "List-Unsubscribe: <#{list_unsub_url}>, <#{list_unsub_mail}>",
      "List-Unsubscribe-Post: List-Unsubscribe=One-Click",
      "",
      body_html
    ].join("\r\n")

    raw = Base64.urlsafe_encode64(rfc822, padding: false)
    message = Google::Apis::GmailV1::Message.new(raw: raw)

    client.send_user_message("me", message)
  end
end