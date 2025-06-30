desc "Send weekly check in emails to users"
task send_weekly_check_ins: :environment do
  return unless Time.current.wday == 1 # Only run on Mondays

  delay_seconds = 0
  increment = 2

  RoleAssignment.active.find_each do |role_assignment|
    increment += 1
    # SendWeeklyCheckInWorker.perform_in(delay_seconds.seconds, role_assignment.id)
  end
end