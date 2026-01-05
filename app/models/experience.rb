class Experience < ApplicationRecord
  scope :templates, -> { where(template: true) }

  def fork!(session_id)
    Experience.where(template: false, code: self.code, name: self.name, session_id: session_id).first_or_create
  end
end