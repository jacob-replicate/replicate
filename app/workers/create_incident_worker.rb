class CreateIncidentWorker
  include Sidekiq::Worker

  sidekiq_options retry: false, lock: :until_executed

  def perform(member_id, incident)
    member = Member.find_by(id: member_id)
    return unless member.present?
    return unless member.subscribed?
    return unless member.organization.active?
    return unless member.conversations.where("created_at >= ?", 24.hours.ago).blank?

    member_conversation_ids = member.conversations.pluck(:id)
    recent_user_reply_exists = Message.where(conversation_id: member_conversation_ids, user_generated: true).where("created_at >= ?", 3.weeks.ago).any?
    return unless member.created_at > 3.weeks.ago || recent_user_reply_exists

    conversation = Conversation.create!(
      channel: "email",
      context: {
        conversation_type: "coaching",
        incident: incident["prompt"]
      },
      recipient: member,
      subject_line: incident["subject"]
    )

    ConversationDriverWorker.new.perform(conversation.id)
  end
end