desc "Send weekly incidents to members"
task send_weekly_incidents: :environment do
  return unless Time.zone.now.wday == 1

  delay_seconds = 0

  Organization.active.find_each do |organization|
    seen = Conversation.where(recipient: organization.members).pluck(Arel.sql("context ->> 'incident'")).reject(&:blank?)

    available = INCIDENTS.reject { |i| seen.include?(i[:key]) }
    incident  = (available.presence || INCIDENTS).sample

    organization.members.subscribed.find_each do |member|
      delay_seconds += rand(5..9)
      StartWeeklyCoachingEmailWorker.perform_in(delay_seconds.seconds, member.id, incident)
    end
  end
end