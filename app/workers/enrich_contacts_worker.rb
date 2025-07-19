class EnrichContactsWorker
  include Sidekiq::Worker

  def perform(ids_to_enrich)
    Contact.where(id: ids_to_enrich).find_in_batches(batch_size: 10) do |batch|
      url = URI("https://api.apollo.io/api/v1/people/bulk_match?reveal_personal_emails=false&reveal_phone_number=false")

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(url)
      request["Accept"] = "application/json"
      request["Cache-Control"] = "no-cache"
      request["Content-Type"] = "application/json"
      request["x-api-key"] = ENV["APOLLO_TOKEN"]

      payload = {
        details: batch.map { |contact| { id: contact.apollo_id } }
      }

      request.body = payload.to_json

      response = http.request(request)
      next unless response.code.to_i == 200

      parsed = JSON.parse(response.body)
      results = parsed["people"] || []

      results.each do |person|
        enriched_email = person["email"]
        apollo_id = person["id"]

        contact = batch.find { |c| c.apollo_id == apollo_id }
        next unless contact
        next if enriched_email.blank? || enriched_email == contact.email

        contact.update(email: enriched_email)
      end
    end
  end
end