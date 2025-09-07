class FetchContactsWorker
  include Sidekiq::Worker

  sidekiq_options retry: false, lock: :until_executed

  def perform(title_keyword, page, pagination_only = false)
    params = {
      "q_keywords" => title_keyword,
      "person_locations[]" => "United States",
      "organization_num_employees_ranges[]" => "100,1000",
      "contact_email_status[]" => "verified",
      "per_page" => "100",
      "page" => page.to_s
    }

    url = URI("https://api.apollo.io/api/v1/mixed_people/search?#{URI.encode_www_form(params)}")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(url)
    request["Accept"] = "application/json"
    request["Cache-Control"] = "no-cache"
    request["Content-Type"] = "application/json"
    request["x-api-key"] = ENV["APOLLO_TOKEN"]

    response = http.request(request)
    case response.code.to_i
      when 429
        Rails.logger.warn "[FetchContactsWorker] Rate limited (429) - retrying in 60s"
        FetchContactsWorker.perform_in(60.seconds, title_keyword, page, pagination_only)
        return
      when 500..599
        Rails.logger.warn "[FetchContactsWorker] Server error (#{response.code}) - retrying in 2m"
        FetchContactsWorker.perform_in(2.minutes, title_keyword, page, pagination_only)
        return
      when 200
        json = JSON.parse(response.body)
        return json["pagination"] if pagination_only
      else
        Rails.logger.error "[FetchContactsWorker] Unexpected response #{response.code}: #{response.body}"
        return
    end

    json = JSON.parse(response.body)

    return json["pagination"] if pagination_only

    people = (json["contacts"] + json["people"]).uniq { |p| p["id"] }

    people.each do |person|
      source = "apollo"
      external_id = person["id"]

      contact = Contact.find_or_initialize_by(source: source, external_id: external_id)
      new_contact = contact.new_record?

      contact.assign_attributes(
        cohort: title_keyword.downcase,
        name: person["name"],
        email: person["email"],
        location: person["present_raw_address"] || [person["city"], person["state"], person["country"]].compact.join(", "),
        company_domain: person.dig("account", "primary_domain"),
        state: person["state"],
        source: source,
        external_id: external_id,
        metadata: person.deep_stringify_keys
      )

      contact.save!
    end
  end
end