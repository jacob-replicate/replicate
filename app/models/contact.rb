class Contact < ApplicationRecord
  # has_many :metadata, as: :owner, dependent: :destroy
  has_many :conversations, as: :recipient, dependent: :destroy
  has_many :messages, through: :conversations

  before_save :set_company_domain
  before_save :downcase_email

  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :company_domain, presence: true, format: { with: /\A[a-z0-9.-]+\.[a-z]{2,}\z/i }
  validate :company_domain_not_on_blocklist

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