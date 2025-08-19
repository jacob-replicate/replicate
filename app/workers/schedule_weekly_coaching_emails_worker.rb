class ScheduleWeeklyCoachingEmailsWorker
  include Sidekiq::Worker

  sidekiq_options retry: false, lock: :until_executed

  def perform(current_day_start)
    delay_seconds = 0
    start_time = Time.at(current_day_start) + 10.hours

    jobs = []

    Organization.active.find_each do |organization|
      seen = Conversation.where(recipient: organization.members).pluck(Arel.sql("context ->> 'incident'")).reject(&:blank?)

      available = INCIDENTS.reject { |i| seen.include?(i) }
      incident  = (available.presence || INCIDENTS).sample

      organization.members.subscribed.find_each do |member|
        delay_seconds += rand(10..15)
        jobs << [start_time + delay_seconds.seconds, delay_seconds, member.id, incident, "---", organization.id, organization.active?, member.subscribed]
        StartWeeklyCoachingEmailWorker.perform_at(start_time + delay_seconds.seconds, member.id, incident, current_day_start)
      end
    end

    jobs
  end
end