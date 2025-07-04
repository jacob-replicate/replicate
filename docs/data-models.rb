class Contractor
  has_many :role_assignments, as: :principal
end

class Email
  has_many :role_assignments, as: :resource
  validates :state, inclusion: { in: %w[pending_review pending_approval pending_delivery delivered failed] }
end

class RoleAssignment
  belongs_to :resource, polymorphic: true
  belongs_to :principal, polymorphic: true

  before_validation :validate_contractor_permissions, if: -> { principal.is_a?(Contractor) }

  def validate_contractor_permissions
    return if resource.nil? || principal.nil?

    if resource.is_a?(Email) && principal.role_assignments.where(resource_type: "Email").count >= 10
      errors.add(:base, "Contractors can only have up to 10 emails in their queue at a time.")
    end
  end
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