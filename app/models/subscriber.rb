class Subscriber < ApplicationRecord
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: {
    with: URI::MailTo::EMAIL_REGEXP,
    message: "must be a valid email address"
  }

  validates :subscribed, inclusion: { in: [true, false] }

  before_validation :normalize_email

  private

  def normalize_email
    self.email = email.to_s.strip.downcase
  end
end