class Element < ApplicationRecord
  belongs_to :conversation, optional: true
  belongs_to :element, optional: true
  belongs_to :experience

  has_many :elements, dependent: :destroy

  validates :code, :experience, presence: true
  validates :code, inclusion: { in: ["ConversationList", "ConversationListRow", "Incident"] }

  scope :root_level, -> { where(element_id: nil) }

  def fork!(new_experience, parent_element = nil)
    new_element = Element.create!(
      code: self.code,
      context: self.context,
      conversation: self.conversation,
      element: parent_element,
      experience: new_experience
    )

    self.elements.each do |child_element|
      child_element.fork!(new_experience, new_element)
    end
  end
end