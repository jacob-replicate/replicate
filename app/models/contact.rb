class Contact < ApplicationRecord
  has_many :conversations, as: :recipient, dependent: :destroy
  has_many :messages, through: :conversations

  before_save :set_company_domain
  before_save :downcase_email

  validates :name, presence: true
  # validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  # validates :company_domain, presence: true, format: { with: /\A[a-z0-9.-]+\.[a-z]{2,}\z/i }
  # validate :company_domain_not_on_blocklist

  def last_system_message
    messages.where(user_generated: false).order(created_at: :desc).first
  end

  def last_user_message
    messages.where(user_generated: true).order(created_at: :desc).first
  end

  def user_waiting_for_reply?
    last_user_message_sent_at = last_user_message&.created_at
    last_system_message_sent_at = last_system_message&.created_at
    last_user_message_sent_at.present? && last_system_message_sent_at.present? && last_user_message_sent_at > last_system_message_sent_at
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

  def self.fetch(title)
    page_count = FetchContactsWorker.new.perform(title, 1, true)["total_pages"]

    1.upto(page_count) do |page|
      FetchContactsWorker.perform_async(title, page)
    end
  end

  private

  def set_company_domain
    if email.present? && company_domain.blank?
      self.company_domain = email.split('@').last
    end
  end

  def downcase_email
    self.email = email.downcase if email.present?
  end

  def company_domain_not_on_blocklist
    blocked_domains = [
      "givecampus.com",
      "hashicorp.com",
      "ibm.com"
    ]

    if company_domain.present? && blocked_domains.include?(company_domain.downcase)
      errors.add(:company_domain, "is blocked")
    end
  end
end