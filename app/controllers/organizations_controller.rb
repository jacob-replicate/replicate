# app/controllers/organizations_controller.rb
class OrganizationsController < ApplicationController
  protect_from_forgery with: :null_session # if you're submitting JSON from the frontend without auth tokens

  def create
    name = params[:name]
    email = params[:email]
    engineer_emails = extract_emails(params[:engineer_emails])

    if name.blank? || email.blank? || engineer_emails.empty?
      return render json: { error: "Missing required fields" }, status: :unprocessable_entity
    end

    ActiveRecord::Base.transaction do
      org = Organization.create!(name: name)

      org.members.create!(
        name: name,
        email: email,
        role: "owner",
        should_receive_emails: false
      )

      engineer_emails.each do |eng_email|
        org.members.create!(
          email: eng_email,
          role: "engineer",
          should_receive_emails: true
        )
      end

      render json: { status: "ok" }, status: :created
    end
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def extract_emails(raw)
    return [] if raw.blank?

    raw
      .split(/[\n, ]+/)
      .map(&:strip)
      .reject(&:blank?)
      .uniq
  end
end