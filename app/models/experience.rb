class Experience < ApplicationRecord
  belongs_to :topic, optional: true

  has_many :elements, dependent: :destroy

  validates :code, :name, presence: true
  validates :template, inclusion: { in: [true, false] }

  scope :templates, -> { where(template: true) }

  def fork!(session_id)
    new_experience = Experience.where(template: false, code: self.code, name: self.name, description: self.description, session_id: session_id).first_or_create

    if new_experience.elements.count == 0
      elements.root_level.each do |element|
        element.fork!(new_experience)
      end
    end

    new_experience.reload
  end
end