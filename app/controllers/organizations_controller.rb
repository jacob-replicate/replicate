class OrganizationsController < ApplicationController
  protect_from_forgery with: :null_session

  def create
    return head(:bad_request) if owner_name.blank? || owner_email.blank?

    org = Organization.create!(access_end_date: 3.months.from_now.end_of_month)
    members_to_create.each { |member_info| org.members.create!(name: member_info[:name], email: member_info[:email], role: member_info[:role]) }

    ScheduleWeeklyIncidentsWorker.perform_async([org.id], Time.current.to_i, Time.current.beginning_of_day.to_i)

    head :ok
  rescue => e
    Rails.logger.error("Error creating organization: #{e.full_message}")
    org&.destroy if org.present?

    head :bad_request
  end

  private

  def owner_name
    params[:name].to_s.squish
  end

  def owner_email
    EmailExtractor.call(params[:email]).first
  end

  def engineer_emails
    EmailExtractor.call(params[:engineer_emails]) - [owner_email]
  end

  def members_to_create
    [{ name: owner_name, email: owner_email, role: "owner" }] + engineer_emails.map { |email| { email: email, role: "engineer" }}
  end
end