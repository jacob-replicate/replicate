# spec/workers/send_cold_email_worker_spec.rb
require "rails_helper"

RSpec.describe SendColdEmailWorker, type: :worker do
  subject(:worker) { described_class.new }

  let(:contact) { create(:contact, email: "jacob@replicate.info", contacted: false, state: US_STATES.first) }
  let(:inbox)   { INBOXES.first }
  let(:variant) { ColdEmailVariants.build(inbox: inbox, contact: contact) }
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
      let(:monday_10am_et_utc) { Time.zone.parse("2025-09-08 14:00:00 UTC") } # 10am ET Monday

      it "sends via Gmail API and marks contact contacted" do
        Timecop.freeze(monday_10am_et_utc) do
          expect(client).to receive(:send_user_message).with("me", instance_of(Google::Apis::GmailV1::Message))
          worker.perform(contact.id, inbox, variant)
          expect(contact.reload.contacted).to eq(true)
        end
      end

      it "builds the correct RFC822 message body (headers + body)" do
        captured_message = nil

        Timecop.freeze(monday_10am_et_utc) do
          allow(client).to receive(:send_user_message) do |_, msg|
            captured_message = msg
          end

          worker.perform(contact.id, inbox, variant)
        end

        expect(captured_message).to be_a(Google::Apis::GmailV1::Message)

        raw = captured_message.raw

        # Future-proof: decode if it's base64url; otherwise treat as plain text.
        decoded =
          begin
            Base64.urlsafe_decode64(raw)
          rescue ArgumentError
            raw
          end

        expect(inbox["from_name"]).to be_present
        expect(inbox["email"]).to be_present
        expect(variant["body_html"]).to include("Hi #{contact.first_name},")
        expect(decoded).to include("To: #{contact.email}")
        expect(decoded).to include("From: #{inbox['from_name']} <#{inbox['email']}>")
        expect(decoded).to include("Reply-To: #{inbox['email']}")
        expect(decoded).to match(/^Date: .+$/)
        expect(decoded).to include("Subject: #{variant['subject']}")
        expect(decoded).to include("MIME-Version: 1.0")
        expect(decoded).to include("Content-Type: text/html; charset=UTF-8")
        expect(decoded).to include("List-Unsubscribe: <https://replicate.info/contacts/#{contact.id}/unsubscribe>, <mailto:#{inbox['email']}?subject=unsubscribe>")
        expect(decoded).to include("List-Unsubscribe-Post: List-Unsubscribe=One-Click")
        expect(decoded).to include(variant["body_html"])
      end
    end
  end
end