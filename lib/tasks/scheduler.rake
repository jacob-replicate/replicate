desc "Send weekly incidents to members"
task schedule_weekly_incidents: :environment do
  if Time.zone.now.wday == 2
    ScheduleWeeklyIncidentsWorker.perform_async(nil, nil, Time.find_zone("America/New_York").now.beginning_of_day)
  end
end