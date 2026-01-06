class Experience < ApplicationRecord
  has_many :elements, dependent: :destroy

  validates :code, :name, presence: true

  scope :templates, -> { where(template: true) }

  def fork!(session_id)
    Experience.where(template: false, code: self.code, name: self.name, session_id: session_id).first_or_create
  end
end