class Topic < ApplicationRecord
  STATES = %w[pending populating populated].freeze

  has_many :conversations, dependent: :destroy

  validates :name, :description, presence: true
  validates :state, inclusion: { in: STATES }

  after_initialize :set_default_state, if: :new_record?

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

  private

  def set_default_state
    self.state ||= "pending"
  end
end