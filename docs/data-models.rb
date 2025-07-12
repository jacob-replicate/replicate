[
  {
    primary_observation: "Search for archived users feels much slower after support filters were added",
    root_cause: "Missing database index"
  },
  {
    primary_observation: "Audit logs show a spike in query count when toggling between user roles",
    root_cause: "N+1 query introduced in permissions lookup"
  },
  {
    primary_observation: "Customer settings take longer to save after MFA settings were updated",
    root_cause: "New background job blocks main thread"
  },
].each_with_index do |context, i|
  puts "Iteration: ##{i}"
  puts "Observeration: #{context[:primary_observation]}\nRoot Cause: #{context[:root_cause]}"
  puts
  puts "Intro: #{Prompt.new(:coaching_intro, context: context).execute}"
  puts "---"
end; nil


# name
# email
# magic_token
# auto_approve_reviews - default false
# parallel_email_limit - default 1
# daily_email_limit    - default 25
# approved - default false
class Contractor
  has_many :role_assignments, as: :principal
  has_many :emails, through: :role_assignments, source: :resource, source_type: 'PaidEmail'

  before_validation :generate_magic_token

  def generate_magic_token
    self.magic_token ||= SecureRandom.hex(10)
  end

  def pending_payout_amount(start_date = Time.now.utc.beginning_of_month, cutoff_date = Time.now.utc.end_of_month)
    emails.where("created_at > ? AND created_at < ?", start_date, cutoff_date).sum(:price_paid) || 0
  end
end

class PaidConversation
  has_many :paid_emails
  belongs_to :contact

  def draft_next_outreach
    prompt = emails.empty? ? :draft_initial_cold_email : :draft_follow_up_email
    email_content = Prompt.new(prompt, input: { contact: contact.relevant_metadata }).execute
    emails.create(content: email_content, user_generated: false, state: "needs_review")
  end
end

# user_generated
# price_paid
# review_started_at
# review_submitted_at
# review_approved_at
class PaidEmail
  PAID_STATES = ["pending_approval", "approved", "skipped", "rejected", "delivered", "failed"]

  belongs_to :paid_conversation
  has_many :role_assignments, as: :resource
  validates :state, inclusion: { in: %w[needs_review in_review pending_approval approved skipped delivered failed] }

  before_update :calculate_price_paid_for_review
  before_update :regenerate_email, if: -> { state_changed? && state == "rejected" }

  scope :submitted_today, -> { where("review_submitted_at > ?", 24.hours.ago) }
  scope :in_review, -> { where(state: "in_review") }

  def calculate_price_paid_for_review
    return unless PAID_STATES.include?(state) && price_paid.blank?
    self.price_paid ||= conversation.emails.user_generated.any? ? 2 : 0.5
  end
end

class RoleAssignment
  belongs_to :resource, polymorphic: true
  belongs_to :principal, polymorphic: true

  before_validation :validate_contractor_permissions, if: -> { principal.is_a?(Contractor) }

  def validate_contractor_permissions
    return if resource.nil? || principal.nil?
    return unless resource.is_a?(PaidEmail)
    emails = principal.emails

    if emails.in_review.count >= principal.parallel_email_limit
      errors.add(:base, "You can only have up to 5 emails in their queue at a time.")
    elsif emails.submitted_today.count >= principal.daily_email_limit
      errors.add(:base, "You can only submit #{principal.daily_email_limit} emails for review per day.")
    elsif emails.where(contact: resource.contact, state: "rejected").any?
      errors.add(:base, "One of your previous emails in this conversation was rejected.")
    elsif emails.where(state: "rejected").count > 5
      errors.add(:base, "You have too many rejected emails, and can no longer accept new assignments.")
    elsif !(principal.approved)
      errors.add(:base, "You are not currently able to accept new assignments.")
    end
  end
end