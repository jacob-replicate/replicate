require "rails_helper"

RSpec.describe EnrichContactsWorker, type: :worker do
  def http_response(code:, body: "")
    instance_double("Net::HTTPResponse", code: code.to_s, body: body)
  end

  let(:url) do
    URI("https://api.apollo.io/api/v1/people/bulk_match?reveal_personal_emails=false&reveal_phone_number=false")
  end

  let(:http) { instance_double(Net::HTTP) }
  let(:old_token) { ENV["APOLLO_TOKEN"] }

  before do
    ENV["APOLLO_TOKEN"] = "test-token"

    # Return our double for HTTP; allow the attribute-writers used in worker
    allow(Net::HTTP).to receive(:new).with(url.host, url.port).and_return(http)
    allow(http).to receive(:use_ssl=)
    allow(http).to receive(:open_timeout=)
    allow(http).to receive(:read_timeout=)
  end

  after { ENV["APOLLO_TOKEN"] = old_token }

  describe "#perform" do
    context "early returns" do
      it "returns when given no matching contacts" do
        expect(Net::HTTP).not_to receive(:new)
        described_class.new.perform([])
      end

      it "returns when all contacts have blank external_id" do
        c1 = create(:contact, external_id: nil)
        c2 = create(:contact, external_id: "")

        expect(Net::HTTP).not_to receive(:new)
        described_class.new.perform([c1.id, c2.id])
      end
    end

    context "200 response with matches" do
      let!(:c_ok)   { create(:contact, external_id: "A123", email: "email_not_unlocked@domain.com", score: 10) }
      let!(:c_lock) { create(:contact, external_id: "B456", email: "email_not_unlocked@domain.com", score: 7) }
      let!(:c_neg)  { create(:contact, external_id: "C789", email: "email_not_unlocked@domain.com", score: -4) }

      let(:payload_matches) do
        {
          "matches" => [
            { "id" => "A123", "email" => "valid@example.com" },                 # should set email
            { "id" => "B456", "email" => "email_not_unlocked@domain.com" },     # should flip positive score once
            { "id" => "C789", "email" => "" },                                   # blank email: negative/zero score should not flip
            { "id" => "Z999", "email" => "unknown@example.com" },                # no local contact — ignored
            nil                                                                  # blank entry — ignored
          ]
        }.to_json
      end

      before do
        # Capture the request passed to http.request so we can assert on headers/body
        @captured_request = nil
        allow(http).to receive(:request) do |req|
          @captured_request = req
          http_response(code: 200, body: payload_matches)
        end
      end

      it "updates email for unlocked matches and flips only positive scores for locked/blank emails" do
        described_class.new.perform([c_ok.id, c_lock.id, c_neg.id])

        expect(c_ok.reload.email).to eq("valid@example.com")

        expect(c_lock.reload.score).to eq(-7)   # flipped
        expect(c_neg.reload.score).to eq(-4)    # unchanged (already <= 0)

        # request verification
        expect(@captured_request).to be_a(Net::HTTP::Post)
        expect(@captured_request["x-api-key"]).to eq("test-token")
        body_hash = JSON.parse(@captured_request.body)
        expect(body_hash["details"]).to match_array(
          [
            { "id" => "A123" },
            { "id" => "B456" },
            { "id" => "C789" }
          ]
        )
      end
    end

    context "non-200 responses" do
      let!(:contact) { create(:contact, external_id: "A1", email: "email_not_unlocked@domain.com", score: 3) }

      it "does nothing and returns on non-200" do
        allow(http).to receive(:request).and_return(http_response(code: 500, body: "{}"))
        described_class.new.perform([contact.id])
        expect(contact.reload.email).to eq("email_not_unlocked@domain.com")
        expect(contact.score).to eq(3)
      end
    end

    context "200 with missing or empty matches" do
      let!(:contact) { create(:contact, external_id: "A1", email: "email_not_unlocked@domain.com", score: 9) }

      it "does nothing when 'matches' key is missing" do
        allow(http).to receive(:request).and_return(http_response(code: 200, body: "{}"))
        described_class.new.perform([contact.id])
        expect(contact.reload.email).to eq("email_not_unlocked@domain.com")
        expect(contact.score).to eq(9)
      end

      it "does nothing when 'matches' is []" do
        allow(http).to receive(:request).and_return(http_response(code: 200, body: { matches: [] }.to_json))
        described_class.new.perform([contact.id])
        expect(contact.reload.email).to eq("email_not_unlocked@domain.com")
        expect(contact.score).to eq(9)
      end
    end
  end
end