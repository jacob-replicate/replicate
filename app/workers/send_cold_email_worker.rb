class SendColdEmailWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, backtrace: false

  def perform(contact_id, subject, body_html, inbox)
    contact = Contact.find(contact_id)
    acquired = Sidekiq.redis { |r| r.set("cold_email_idempotency:#{contact.id}", 1, nx: true, ex: 172_800) }
    return unless acquired

    gmail = GmailClient.new(api_key: inbox["api_key"] || inbox[:api_key])
    from_email = inbox["email"]     || inbox[:email]
    from_name  = inbox["from_name"] || inbox[:from_name]

    headers = {
      "List-Unsubscribe" => "<https://replicate.info/unsub/#{contact.id}>, <mailto:#{from_email}?subject=unsubscribe>",
      "List-Unsubscribe-Post" => "List-Unsubscribe=One-Click"
    }

    gmail.send_html(
      from_email: from_email,
      from_name:  from_name,
      to:         contact.email,
      subject:    subject,
      html:       body_html,
      headers:    headers
    )
  end
end