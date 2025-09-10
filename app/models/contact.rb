class Contact < ApplicationRecord
  has_many :conversations, as: :recipient, dependent: :destroy
  has_many :messages, through: :conversations

  before_save :set_company_domain
  before_save :downcase_email

  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validate :name_must_have_two_words

  scope :contacted, -> { where(contacted: true) }
  scope :enriched, -> { where.not(email: "email_not_unlocked@domain.com").where.not(email: nil) }
  scope :unenriched, -> { where("email IS NULL OR email = ?", "email_not_unlocked@domain.com") }
  scope :us, -> { where(state: US_STATES) }

  def passed_bounce_check?
    return false if company_domain_on_blocklist?

    uri = URI("https://api.usebouncer.com/v1.1/email/verify?email=#{email}")
    request = Net::HTTP::Get.new(uri)
    request['x-api-key'] = ENV["BOUNCER_API_KEY"]

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    result = JSON.parse(response.body)
    result["status"] == "deliverable" && result["reason"] == "accepted_email"
  end

  def first_name
    return nil unless name.present?

    names = name.split(' ')
    return nil unless names.size == 2

    names.first
  end

  def metadata_for_gpt
    raw = metadata.deep_symbolize_keys

    {
      id: raw[:person_id] || raw[:id],
      name: raw[:name],
      title: raw[:title],
      email: raw[:email],
      location: raw[:present_raw_address] || [raw[:city], raw[:state], raw[:country]].compact.join(", "),
      linkedin: raw[:linkedin_url],
      headline: raw[:headline],
      company: {
        name: raw.dig(:organization, :name),
        domain: raw.dig(:organization, :primary_domain),
        linkedin: raw.dig(:organization, :linkedin_url),
        angellist: raw.dig(:organization, :angellist_url),
        hq_location: raw.dig(:organization, :raw_address),
        founded_year: raw.dig(:organization, :founded_year),
        headcount_growth_6mo: raw.dig(:organization, :organization_headcount_six_month_growth),
        headcount_growth_12mo: raw.dig(:organization, :organization_headcount_twelve_month_growth)
      },
      employment_history: Array(raw[:employment_history]).map do |job|
        {
          title: job[:title],
          org: job[:organization_name],
          start: job[:start_date],
          end: job[:end_date]
        }
      end
    }
  end

  private

  def name_must_have_two_words
    word_count = name.to_s.strip.split.size
    errors.add(:name, "must include at least first and last name") if word_count != 2
  end

  def set_company_domain
    if email.present?
      self.company_domain = email.split('@').last
    end
  end

  def downcase_email
    self.email = email.downcase if email.present?
  end

  def company_domain_on_blocklist?
    [
      "givecampus",
      "replicate",
      "hashicorp",
      ".edu",
      ".mil",
      ".gov",
      "ibm"
    ].any? { |banned_phrase| company_domain.to_s.downcase.include?(banned_phrase) }
  end
end