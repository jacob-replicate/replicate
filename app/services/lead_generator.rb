1752945044

class LeadGenerator
  def initialize
    @leads = []
    @rejected_leads = []
    @ids_to_enrich = []
    @page_size = 10
    @page = 50
    @raw_response = nil
  end

  def call
    url = URI("https://api.apollo.io/api/v1/mixed_people/search?person_titles[]=staff%20engineer&include_similar_titles=false&person_locations[]=United%20States&organization_num_employees_ranges[]=250%2C3000&contact_email_status[]=verified&per_page=#{@page_size}&page=#{@page}")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(url)
    request["accept"] = 'application/json'
    request["Cache-Control"] = 'no-cache'
    request["Content-Type"] = 'application/json'
    request["x-api-key"] = ENV["APOLLO_TOKEN"]

    @raw_response = JSON.parse(http.request(request).read_body)

    puts @raw_response["pagination"]
    puts "---------"

    people = extract_relevant_people(@raw_response)
  end

  def format_contact_for_gpt(contact)
    {
      id: contact["person_id"],
      name: contact["name"],
      title: contact["title"],
      location: contact["present_raw_address"] || "#{contact['city']}, #{contact['state']}, #{contact['country']}",
      email: contact["email"],
      linkedin: contact["linkedin_url"],
      company: {
        name: contact.dig("account", "name"),
        domain: contact.dig("account", "primary_domain"),
        linkedin: contact.dig("account", "linkedin_url"),
        angellist: contact.dig("account", "angellist_url"),
        hq_location: contact.dig("account", "raw_address"),
        founded_year: contact.dig("account", "founded_year"),
        headcount_growth_6mo: contact.dig("account", "organization_headcount_six_month_growth"),
        headcount_growth_12mo: contact.dig("account", "organization_headcount_twelve_month_growth")
      },
      employment_history: contact["employment_history"]&.map do |job|
        {
          title: job["title"],
          description: job["description"],
          org: job["organization_name"],
          start: job["start_date"],
          end: job["end_date"]
        }
      end
    }
  end

  def extract_relevant_people(response)
    people = (response["contacts"] + response["people"]).map { |person| format_contact_for_gpt(person) }

    people.reject! do |person|
      person[:employment_history].any? { |employer| ["ibm", "givecampus", "hashicorp"].include?(employer[:org]) }
    end

    people.each { |person| score_lead(person) }

    if @ids_to_enrich.present?
      enrich_leads
    end
  end

  def score_lead(person)
    scoring = Prompts::LeadScoring.new(context: { lead_metadata: person }).call rescue {}

    puts "#{person[:name]} - #{person[:title]} - #{person[:linkedin]}"
    scoring.each { |key, value| puts "#{key.to_s.humanize}: #{value}" }
    puts "---"

    action = scoring["action"]
    if action == "email"
      @leads << person
    elsif action == "enrich"
      @ids_to_enrich << person[:id]
      # TODO: Enrich
    else
      @rejected_leads << person
    end
  end

  def enrich_leads
    @ids_to_enrich.each_slice(10) do |batch|
      url = URI("https://api.apollo.io/api/v1/people/bulk_match?reveal_personal_emails=false&reveal_phone_number=false")

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(url)
      request["accept"] = 'application/json'
      request["Cache-Control"] = 'no-cache'
      request["Content-Type"] = 'application/json'
      request["x-api-key"] = ENV['APOLLO_TOKEN']

      payload = {
        details: batch.map { |id| { id: id } }
      }

      payload = {
        details: [ { id: "600aef3be3d5aa00014150a0" } ]
      }

      request.body = payload.to_json

      response = http.request(request)
      # puts response.code
      # puts JSON.parse(response.body.force_encoding('UTF-8'))
    end
  end
end