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