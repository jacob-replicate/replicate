class Experience < ApplicationRecord
  STATES = %w[pending populating populated].freeze

  belongs_to :topic, optional: true

  has_many :elements, dependent: :destroy

  validates :code, :name, presence: true
  validates :template, inclusion: { in: [true, false] }
  validates :description, length: { maximum: 300 }
  validates :state, inclusion: { in: STATES }

  after_initialize :set_default_state, if: :new_record?

  scope :templates, -> { where(template: true) }
  scope :pending, -> { where(state: "pending") }
  scope :populating, -> { where(state: "populating") }
  scope :populated, -> { where(state: "populated") }

  def pending?
    state == "pending"
  end

  def populating?
    state == "populating"
  end

  def populated?
    state == "populated"
  end

  def fork!(session_id)
    new_experience = Experience.where(template: false, code: self.code, name: self.name, description: self.description, topic_id: self.topic_id, session_id: session_id).first_or_create

    if new_experience.elements.count == 0
      elements.root_level.each do |element|
        element.fork!(new_experience)
      end
    end

    new_experience.reload
  end

  private

  def set_default_state
    self.state ||= "pending"
  end
end