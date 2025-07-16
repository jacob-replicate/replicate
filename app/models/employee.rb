class Employee < ApplicationRecord
  belongs_to :organization

  ROLES = %w[owner engineer]

  validates :email, presence: true, uniqueness: { scope: :organization_id }
  validates :role, presence: true, inclusion: { in: ROLES }

  def owner?
    role == "owner"
  end

  def engineer?
    role == "engineer"
  end
end