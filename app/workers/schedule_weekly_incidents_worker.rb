class ScheduleWeeklyIncidentsWorker
  include Sidekiq::Worker

  sidekiq_options retry: false, lock: :until_executed

  def perform(organization_ids, start_time, current_day_start)
    return false # since you pivoted

    start_time = start_time.present? ? Time.at(start_time) : Time.at(current_day_start).advance(hours: 12)
    delay_seconds = 0

    organizations = organization_ids.present? ? Organization.active.where(id: organization_ids) : Organization.active
    return if organizations.blank?

    organizations.order(:access_end_date).each do |organization|
      incident = NextIncidentSelector.call(organization)
      next if incident.blank?

      organization.members.subscribed.order(role: :desc).each do |member| # to email owners first during trial submission
        perform_at = (start_time + delay_seconds.seconds).change(usec: 0)
        CreateIncidentWorker.perform_at(perform_at, member.id, incident)

        delay_seconds += delay_second_increment
      end
    end
  end

  private

  def delay_second_increment
    rand(10..15)
  end
end