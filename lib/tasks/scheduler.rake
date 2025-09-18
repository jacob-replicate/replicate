desc "Send weekly incidents to members"
task schedule_weekly_incidents: :environment do
  time = Time.find_zone("America/New_York")
  if time.now.wday == 1
    ScheduleWeeklyIncidentsWorker.perform_async(nil, nil, time.now.beginning_of_day.to_i)
  end
end