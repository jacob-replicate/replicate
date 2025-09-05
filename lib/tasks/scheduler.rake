desc "Send weekly incidents to members"
task schedule_weekly_incidents: :environment do
  return unless Time.zone.now.wday == 1
  ScheduleWeeklyIncidentsWorker.perform_async(Time.zone.now.beginning_of_day.to_i)
end