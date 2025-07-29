class Contact < ApplicationRecord
  has_many :conversations, as: :recipient, dependent: :destroy
  has_many :messages, through: :conversations

  before_save :set_company_domain
  before_save :downcase_email

  validates :name, presence: true
  # validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  # validates :company_domain, presence: true, format: { with: /\A[a-z0-9.-]+\.[a-z]{2,}\z/i }
  # validate :company_domain_not_on_blocklist

  def first_name
    return nil unless name.present?

    names = name.split(' ')
    return nil unless names.size == 2

    names.first
  end

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
      FetchContactsWorker.perform_in((page * 5).seconds, title, page)
    end
  end

  def self.report(cohort: nil)
    scope = cohort.present? ? where(cohort: cohort) : all

    score_counts = scope.group(:score).count
    total = scope.count
    scored = scope.where.not(score: nil).count
    unscored = total - scored

    puts "Lead Quality Report#{cohort ? " (cohort: #{cohort})" : ''}"
    puts "----------------------------------"
    puts "Total contacts: #{total}"
    puts "Scored: #{scored}"
    puts "Unscored: #{unscored}"
    puts

    sorted_scores = score_counts.keys.compact.sort.reverse

    sorted_scores.each do |score|
      contacts = scope.where(score: score)
      conversation_count = Conversation.where(recipient_id: contacts.pluck(:id)).count
      puts "Score #{score}: #{contacts.count} contacts, #{conversation_count} conversations"
    end
  end

  def self.fetch_all
    keywords = [
      "application security",
      "backend",
      "cloud",
      "infrastructure",
      "internal tools",
      "lead",
      "software",
      "observability",
      "platform",
      "principal",
      "security",
      "senior staff",
      "site reliability",
      "sre",
      "staff",
      "tooling",
    ]

    keywords.uniq.map(&:downcase).each_with_index do |keyword, i|
      offset = (i * 2).minutes
      begin
        pagination = FetchContactsWorker.new.perform(keyword, 1, true)
        page_count = pagination["total_pages"]
      rescue => e
        Rails.logger.error "[Contact.fetch_all] Failed to fetch page count for #{keyword}: #{e.class} - #{e.message}"
        next
      end

      1.upto(page_count) do |page|
        FetchContactsWorker.perform_in((page * 5).seconds + offset, keyword, page)
      end
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