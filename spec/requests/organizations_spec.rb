# spec/requests/organizations_controller_spec.rb
require "rails_helper"

RSpec.describe "OrganizationsController#create", type: :request do
  let(:endpoint) { "/organizations" }

  describe "POST /organizations" do
    context "happy path" do
      it "creates org, owner, engineers and enqueues the scheduling job" do
        Timecop.freeze do
          allow(ScheduleWeeklyIncidentsWorker).to receive(:perform_async)

          params = {
            name:  "Jane Owner",
            email: "owner@example.com",
            engineer_emails: "eng1@example.com, eng2@example.com ; ENG3@exaMple.com"
          }

          expect {
            post endpoint, params: params, as: :json
          }.to change(Organization, :count).by(1).and change(Member, :count).by(4)

          expect(response).to have_http_status(:ok)

          org = Organization.last
          # Owner
          owner = org.members.find_by(role: "owner")
          expect(owner).to have_attributes(name: "Jane Owner", email: "owner@example.com")

          engineers = org.members.where(role: "engineer").pluck(:email)
          expect(engineers).to match_array(%w[eng1@example.com eng2@example.com eng3@example.com])
          expect(org.members.pluck(:subscribed).uniq).to eq([true])

          expect(ScheduleWeeklyIncidentsWorker).to have_received(:perform_async).with([org.id], Time.current.to_i, Time.current.beginning_of_day.to_i)
        end
      end
    end

    context "missing required fields" do
      it "returns 400 when owner name is missing" do
        allow(EmailExtractor).to receive(:call).with("owner@example.com").and_return(["owner@example.com"])

        post endpoint, params: { email: "owner@example.com", engineer_emails: "" }, as: :json
        expect(response).to have_http_status(:bad_request)
        expect(Organization.count).to eq(0)
        expect(Member.count).to eq(0)
      end

      it "returns 400 when owner email is missing" do
        allow(EmailExtractor).to receive(:call).with(nil).and_return([])

        post endpoint, params: { name: "Jane Owner", engineer_emails: "" }, as: :json
        expect(response).to have_http_status(:bad_request)
        expect(Organization.count).to eq(0)
        expect(Member.count).to eq(0)
      end
    end

    context "rescue path on member creation error" do
      it "returns 400 and destroys the org if a member create! raises" do
        allow(EmailExtractor).to receive(:call).with("owner@example.com").and_return(["owner@example.com"])
        allow(ScheduleWeeklyIncidentsWorker).to receive(:perform_in)
        allow_any_instance_of(OrganizationsController).to receive(:engineer_emails).and_return(["owner@example.com"]) # same as owner → Member uniqueness should raise

        post endpoint, params: { name: "Jane Owner", email: "owner@example.com", engineer_emails: "owner@example.com" }, as: :json

        expect(response).to have_http_status(:bad_request)
        expect(Organization.count).to eq(0)
        expect(Member.count).to eq(0)
        expect(ScheduleWeeklyIncidentsWorker).not_to have_received(:perform_in)
      end
    end
  end
end