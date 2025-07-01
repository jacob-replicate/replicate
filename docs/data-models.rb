# TEXT email
# TEXT location (e.g., "San Francisco, CA")
# TEXT company_domain
# TEXT state

class Contact < ApplicationRecord
  has_many :conversations, as: :recipient, dependent: :destroy
  has_many :messages, through: :conversations
  before_save :set_company_domain

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :company_domain, presence: true, format: { with: /\A[a-z0-9.-]+\.[a-z]{2,}\z/i }

  def relevant_metadata
    @relevant_metadata ||= begin
      query = "(category = 'company' AND identifier = ?) OR (category = 'contact' AND identifier = ?)"
      records = Metadata.where(query, company_domain, email).where.not(content: nil).pluck(:content)

      records.reduce({}) do |summary, json|
        summary.deep_merge(json) rescue summary
      end.to_json
    end
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

  def queue_most_impactful_outreach
    if conversations.empty?
      email_timestamp = Prompt.new(:fetch_ideal_email_send_time, input: { user_location: location }).execute
      SendEmailWorker.perform_at(email_timestamp, "Recipient", id, :initial_cold_email)
    elsif user_waiting_for_reply?
      # TODO: Queue up reply based off last_user_message.conversation
    else
      # TODO: Send relevant follow up email
    end
  end

  private

  def set_company_domain
    if email.present? && company_domain.blank?
      self.company_domain = email.split('@').last
    end
  end
end

class Metadata
  #- TEXT category
  #- TEXT identifier
  #- JSONB content
end

#----------------------
#
#Organization
#- has_many :role_assignments
#- name
#
#----------------------
#
#Team
#- organization_id
#- name
#- state - :active, :archived, :deleted
#
#----------------------
#
#User
#- email
#- name
#- confirmed_at
#
#----------------------
#
#RoleAssignment
#- principal_id
#- principal_type
#- resource_id - 1, 2, 3, etc.
#- resource_type - Organization, Team, Folder, Session, Project, etc.
#- role - :administrator, :manager, :user
#
#  :administrator (org ID)
#    * Billing
#    * Revoke access
#    * View 2FA reporting
#
#  :manager (team ID)
#    * CRUD teams
#    * CRUD assignments
#    * CRUD questionnaires
#    * Invite users
#
#  :user (team / org ID)
#    * View reporting (questionnaire responses, blind spot summaries)
#    * CRUD sessions