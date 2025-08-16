desc "Send weekly incidents to members"
task send_weekly_incidents: :environment do
  return unless Time.current.wday == 1 # Only run on Mondays

  delay_seconds = 0
  current_day_start = Time.now.beginning_of_day.to_i
  Member.where(subscribed: true).order(:email_domain).find_each do |member|
    delay_seconds += rand(5..9)
    StartWeeklyCoachingEmailWorker.perform_in(delay_seconds.seconds, member.id, current_day_start)
  end
end