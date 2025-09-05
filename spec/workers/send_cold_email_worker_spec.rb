# spec/workers/send_cold_email_worker_spec.rb
require "rails_helper"

RSpec.describe SendColdEmailWorker, type: :worker do
  subject(:worker) { described_class.new }

  let(:contact) { create(:contact, email: "jacob@replicate.info", contacted: false, state: US_STATES.first) }
  let(:inbox)   { { "email" => "outbound@example.com", "from_name" => "Outbound Bot" } }
  let(:variant) { { "subject" => "Test Subject", "body_html" => "<p>Hello world</p>" } }

  let(:client) { instance_double(Google::Apis::GmailV1::GmailService) }
  let(:authorizer) { instance_double(Google::Auth::ServiceAccountCredentials) }

  before do
    allow(Google::Apis::GmailV1::GmailService).to receive(:new).and_return(client)
    allow(Google::Auth::ServiceAccountCredentials).to receive(:make_creds).and_return(authorizer)
    allow(authorizer).to receive(:update!)
    allow(authorizer).to receive(:fetch_access_token!).and_return({ "access_token" => "token123" })
    allow(client).to receive(:authorization=)
    allow(client).to receive(:send_user_message)
  end

  describe "#perform" do
    context "when contact is missing" do
      it "returns without sending email" do
        expect(client).not_to receive(:send_user_message)
        worker.perform(-1, inbox, variant)
      end
    end

    context "when contact has already been contacted" do
      it "does nothing" do
        contact.update!(contacted: true)
        worker.perform(contact.id, inbox, variant)
        expect(client).not_to have_received(:send_user_message)
      end
    end

    context "when contact email is blank or unenriched" do
      it "returns early for blank email" do
        Contact.where(id: contact.id).update_all(email: nil)
        worker.perform(contact.id, inbox, variant)
        expect(client).not_to have_received(:send_user_message)
      end

      it "returns early for pre-enriched contacts" do
        contact.update!(email: "email_not_unlocked@domain.com")
        worker.perform(contact.id, inbox, variant)
        expect(client).not_to have_received(:send_user_message)
      end
    end

    context "when contact is outside the US" do
      let(:non_us_contact) { create(:contact, email: "intl@example.com", contacted: false, state: "Puerto Rico") }

      it "does nothing and skips sending" do
        worker.perform(non_us_contact.id, inbox, variant)
        expect(client).not_to have_received(:send_user_message)
        expect(non_us_contact.reload.contacted).to eq(false)
      end
    end

    context "when outside weekday hours" do
      around do |ex|
        Timecop.freeze(Time.zone.parse("2024-09-02 20:00:00 UTC")) { ex.run } # 4pm ET Monday
      end

      it "does nothing if weekend" do
        weekend_time = Time.zone.parse("2024-09-01 16:00:00 UTC") # Sunday noon ET
        Timecop.freeze(weekend_time) do
          worker.perform(contact.id, inbox, variant)
        end
        expect(client).not_to have_received(:send_user_message)
      end

      it "does nothing if after hours" do
        after_hours = Time.zone.parse("2024-09-02 23:00:00 UTC") # 7pm ET Monday
        Timecop.freeze(after_hours) do
          worker.perform(contact.id, inbox, variant)
        end
        expect(client).not_to have_received(:send_user_message)
      end
    end

    context "when valid weekday and business hours" do
      it "sends the email via Gmail API and marks contact contacted" do
        time = Time.zone.parse("2025-09-08 16:00:00 UTC") # 10am ET Monday
        Timecop.freeze(time)  do
          expect(client).to receive(:send_user_message).with("me", instance_of(Google::Apis::GmailV1::Message))
          worker.perform(contact.id, inbox, variant)
          expect(contact.reload.contacted).to eq(true)
        end
      end
    end
  end
end