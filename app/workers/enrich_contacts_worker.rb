class EnrichContactsWorker
  include Sidekiq::Worker

  sidekiq_options retry: false, lock: :until_executed

  def perform(ids_to_enrich)
    contacts = Contact.where(id: ids_to_enrich)
    return if contacts.blank?

    ids = contacts.map(&:external_id).reject(&:blank?)
    return if ids.blank?

    url = URI("https://api.apollo.io/api/v1/people/bulk_match?reveal_personal_emails=false&reveal_phone_number=false")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.open_timeout = 5
    http.read_timeout = 10

    request = Net::HTTP::Post.new(url)
    request["Accept"] = "application/json"
    request["Cache-Control"] = "no-cache"
    request["Content-Type"] = "application/json"
    request["x-api-key"] = ENV["APOLLO_TOKEN"]
    request.body = { details: ids.map { |id| { id: id } } }.to_json

    response = http.request(request)
    return unless response.code.to_i == 200

    parsed = JSON.parse(response.body)
    results = parsed["matches"] || []

    results.each do |person|
      next if person.blank?
      enriched_email = person["email"]
      apollo_id = person["id"]
      contact = contacts.find { |c| c.external_id == apollo_id }
      next unless contact

      if enriched_email.blank? || enriched_email == "email_not_unlocked@domain.com"
        contact.update(score: contact.score * -1) if contact.score.to_i > 0
      else
        contact.update(email: enriched_email)
      end
    end
  end
end