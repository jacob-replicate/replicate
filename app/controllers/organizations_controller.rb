class OrganizationsController < ApplicationController
  protect_from_forgery with: :null_session # if you're submitting JSON from the frontend without auth tokens

  def create
    name = params[:name]
    email = params[:email]
    engineer_emails = EmailExtractor.call(params[:engineer_emails])

    if name.blank? || email.blank? || engineer_emails.empty?
      return render json: { error: "Missing required fields" }, status: :unprocessable_entity
    end

    ActiveRecord::Base.transaction do
      org = Organization.create!(access_end_date: 3.months.from_now.end_of_month)

      org.members.create!(
        name: name,
        email: email,
        role: "owner"
      )

      engineer_emails.each { |eng_email| org.members.create(email: eng_email, role: "engineer") }

      # ScheduleWeeklyCoachingEmailsWorker.perform_async([org.id], 1.minute.from_now.to_i, Time.current.beginning_of_day.to_i)
    end

    render json: { status: "ok" }, status: :created
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  end
end