class Conversation < ApplicationRecord
  scope :templates, -> { where(template: true) }

  belongs_to :template_conversation, class_name: "Conversation", foreign_key: :template_id, optional: true

  has_many :forked_conversations, class_name: "Conversation", foreign_key: :template_id, dependent: :nullify
  has_many :messages, dependent: :destroy


  def fork(session_id)
    existing = forked_conversations.find_by(session_id: session_id)
    return existing if existing

    transaction do
      forked = forked_conversations.create!(session_id: session_id, topic: topic)

      message_id_map = {}

      messages.includes(:components).each do |msg|
        new_msg = forked.messages.create!(
          author_avatar: msg.author_avatar,
          author_name: msg.author_name,
          is_system: msg.is_system,
          sequence: msg.sequence
        )

        message_id_map[msg.id] = new_msg.id

        msg.components.each do |comp|
          new_msg.components.create!(
            data: comp.data,
            position: comp.position
          )
        end
      end

      forked
    end
  end
end