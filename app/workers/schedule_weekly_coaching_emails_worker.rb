class ScheduleWeeklyCoachingEmailsWorker
  include Sidekiq::Worker

  sidekiq_options retry: false, lock: :until_executed

  def perform(organization_ids, start_time, current_day_start)
    start_time = start_time.present? ? Time.at(start_time) : Time.at(current_day_start).advance(hours: 10)

    organizations = organization_ids.present? ? Organization.where(id: organization_ids) : Organization.active
    return if organizations.blank?

    delay_seconds = 0

    organizations.find_each do |organization|
      seen_prompts = Conversation.where(recipient: organization.members).pluck(Arel.sql("context ->> 'incident'")).reject(&:blank?)
      available = EMAIL_INCIDENTS.reject { |incident| seen_prompts.include?(incident[:prompt]) }
      incident  = (available.presence || EMAIL_INCIDENTS).sample

      organization.members.subscribed.find_each do |member|
        delay_seconds += rand(10..15)
        # StartWeeklyCoachingEmailWorker.perform_at(start_time + delay_seconds.seconds, member.id, incident, current_day_start)
      end
    end
  end
end