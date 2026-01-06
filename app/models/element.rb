class Element < ApplicationRecord
  belongs_to :conversation
  belongs_to :element
  belongs_to :experience

  has_many :elements, dependent: :destroy

  validates :code, :experience, presence: true
  validates :code, inclusion: { in: ["ConversationList", "Incident"] }
  validates :template, inclusion: { in: [true, false] }
end