class Element < ApplicationRecord
  belongs_to :conversation, optional: true
  belongs_to :element, optional: true
  belongs_to :experience

  has_many :elements, dependent: :destroy

  validates :code, :experience, presence: true

  scope :root_level, -> { where(element_id: nil) }

  def fork!(new_experience, parent_element = nil)
    new_element = Element.create!(
      code: self.code,
      context: self.context,
      conversation: nil, # Forked elements create their own conversations via create_conversation!
      element: parent_element,
      sort_order: self.sort_order,
      experience: new_experience
    )

    self.elements.each do |child_element|
      child_element.fork!(new_experience, new_element)
    end
  end

  def create_conversation!
    convo = case code.to_sym
    when :incident_cta
      create_incident_conversation!
    when :conversation_list_row
      create_question_conversation!
    when :design_review_cta
      raise NotImplementedError, "design_review_cta conversation creation not yet implemented"
    when :question_cta
      raise NotImplementedError, "question_cta conversation creation not yet implemented"
    when :question_cta_option
      raise NotImplementedError, "question_cta_option conversation creation not yet implemented"
    else
      raise ArgumentError, "Unknown element code for conversation creation: #{code}"
    end

    update!(conversation: convo)

    convo
  end

  private

  def create_incident_conversation!
    Conversation.create!(
      channel: "web",
      variant: "incident",
      generation_intent: generation_intent
    )
  end

  def create_question_conversation!
    Conversation.create!(
      channel: "web",
      variant: "question",
      generation_intent: context["name"]
    )
  end
end