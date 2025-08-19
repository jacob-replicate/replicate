class Organization < ApplicationRecord
  has_many :members, dependent: :destroy

  scope :active, -> { where("access_end_date > ?", Time.current) }

  def active?
    access_end_date.present? && access_end_date > Time.current
  end
end