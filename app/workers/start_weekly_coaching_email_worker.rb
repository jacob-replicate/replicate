class StartWeeklyCoachingEmailWorker
  include Sidekiq::Worker

  sidekiq_options retry: false, lock: :until_executed

  def perform(member_id, current_day_start, incident)
    member = Member.find_by(id: member_id)
    return unless member.present? && member.subscribed? && member.organization.active?

    day_start = DateTime.parse(current_day_start)
    day_end = day_start + 24.hours
    return if member.conversations.where("created_at >= ? AND created_at <= ?", day_start, day_start + 1.day)

    conversation = Conversation.create!(
      channel: "email",
      context: {
        conversation_type: "coaching",
        incident: incident
      },
      recipient: member
    )

    ConversationDriverWorker.new.perform(conversation.id)
  end
end