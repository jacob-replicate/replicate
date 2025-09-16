desc "Send weekly incidents to members"
task schedule_weekly_incidents: :environment do
  if Time.zone.now.wday == 2
    ScheduleWeeklyIncidentsWorker.perform_async(nil, nil, Time.zone.now.beginning_of_day.to_i)
  end
end