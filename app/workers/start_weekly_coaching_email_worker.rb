class StartWeeklyCoachingEmailWorker
  include Sidekiq::Worker

  sidekiq_options retry: false, lock: :until_executed

  def perform(member_id, incident)
    member = Member.find_by(id: member_id)
    puts "Member: #{member.name} - #{member.email} - #{incident['prompt']}" if member.present?
    return
    return unless member.present? && member.subscribed? && member.organization.active? && member.conversations.where("created_at >= ?", 24.hours.ago).blank?

    subject = Prompts::CoachingSubjectLine.new(context: { incident: incident }).call rescue ""
    return if subject.blank?

    conversation = Conversation.create!(
      channel: "email",
      context: {
        conversation_type: "coaching",
        incident: incident["prompt"]
      },
      recipient: member
    )

    ConversationDriverWorker.new.perform(conversation.id)
  end
end