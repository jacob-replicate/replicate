class Member < ApplicationRecord
  belongs_to :organization

  ROLES = %w[owner engineer]

  validates :email, presence: true, uniqueness: { scope: :organization_id }
  validates :role, presence: true, inclusion: { in: ROLES }

  before_validation :set_email_domain, if: -> { will_save_change_to_email? }

  def owner?
    role == "owner"
  end

  def engineer?
    role == "engineer"
  end

  private

  def set_email_domain
    raw = email.to_s
    domain = raw.split("@").last.to_s
    domain = domain.strip.downcase
    domain = domain.gsub(/[^\w\.\-]/, "")         # keep a-z0-9 _ . -
    domain = domain.gsub(/\A\.+|\.+\z/, "")       # trim leading/trailing dots
    domain = nil if domain.blank? || !domain.include?(".")

    self.email_domain = domain
  end
end