class CreateIncidentWorker
  include Sidekiq::Worker

  sidekiq_options retry: false, lock: :until_executed

  def perform(member_id, incident)
    member = Member.find_by(id: member_id)
    return unless member.present? && member.subscribed? && member.conversations.where("created_at >= ?", 24.hours.ago).blank?

    conversation = Conversation.create!(
      channel: "email",
      context: {
        conversation_type: "coaching",
        incident: incident["prompt"]
      },
      recipient: member,
      subject_line: incident["subject_lines"].sample,
    )

    ConversationDriverWorker.new.perform(conversation.id)
  end
end