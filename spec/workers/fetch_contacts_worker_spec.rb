require "rails_helper"

RSpec.describe FetchContactsWorker do
  subject(:worker) { described_class.new }

  let(:keyword) { "VP Marketing" }
  let(:page)    { 1 }

  # === Apollo payload fixture (YOUR payload) ================================
  let(:apollo_payload) do
    {
      "pagination" => { "page" => 1, "per_page" => 2, "total_entries" => 2, "total_pages" => 1 },
      "contacts" => [
        {
          "id" => "6462b961ad39c900a3070207",
          "name" => "Josh Garrison",
          "email" => "joshgarrison19@gmail.com",
          "present_raw_address" => "San Francisco Bay Area",
          "city" => "San Francisco",
          "state" => "California",
          "country" => "United States",
          "account" => { "primary_domain" => "apollo.io" }
        },
        {
          "id" => "6596ea42d05a3e00014cf630",
          "name" => "David Malpass",
          "email" => "email_not_unlocked@domain.com",
          "present_raw_address" => "San Francisco, California, United States",
          "city" => "San Francisco",
          "state" => "California",
          "country" => "United States",
          "account" => { "primary_domain" => "apollo.io" }
        }
      ],
      "people" => []
    }
  end
  # ========================================================================

  # ---- HTTP stubbing helpers ---------------------------------------------
  def http_double_with(response)
    http = instance_double(Net::HTTP)
    allow(http).to receive(:use_ssl=)
    allow(http).to receive(:request).and_return(response)
    allow(Net::HTTP).to receive(:new).and_return(http)
    http
  end

  def response_double(code:, body: {})
    instance_double(Net::HTTPResponse, code: code.to_s, body: JSON.dump(body))
  end
  # ------------------------------------------------------------------------

  before do
    allow(described_class).to receive(:perform_in) # spy retries
  end

  describe "#perform" do
    it "returns pagination when pagination_only is true" do
      http_double_with(response_double(code: 200, body: apollo_payload))
      out = worker.perform(keyword, page, true)
      expect(out).to eq({ "page" => 1, "per_page" => 2, "total_entries" => 2, "total_pages" => 1 })
      expect(Contact.count).to eq(0)
    end

    it "creates contacts from the payload (mapping primary fields correctly)" do
      http_double_with(response_double(code: 200, body: apollo_payload))

      expect {
        worker.perform(keyword, page, false)
      }.to change(Contact, :count).by(2)

      josh  = Contact.find_by(external_id: "6462b961ad39c900a3070207", source: "apollo")
      david = Contact.find_by(external_id: "6596ea42d05a3e00014cf630", source: "apollo")

      # cohort downcased from keyword
      expect(josh.cohort).to eq("vp marketing")
      expect(david.cohort).to eq("vp marketing")

      # prefers present_raw_address; falls back would be "city, state, country" (not used here)
      expect(josh.location).to eq("San Francisco Bay Area")
      expect(david.location).to eq("San Francisco, California, United States")

      # basic fields
      expect(josh.name).to eq("Josh Garrison")
      expect(david.name).to eq("David Malpass")

      # email: your worker uses person["email"] (gmail for Josh, nil for David)
      expect(josh.email).to eq("joshgarrison19@gmail.com")
      expect(david.email).to eq("email_not_unlocked@domain.com")

      # domain + state mapping
      expect(josh.company_domain).to eq("gmail.com")
      expect(josh.state).to eq("California")
      expect(david.company_domain).to eq("domain.com")
      expect(david.state).to eq("California")

      # metadata saved as stringified hash
      expect(josh.metadata).to be_a(Hash)
      expect(josh.metadata["id"]).to eq("6462b961ad39c900a3070207")
    end

    it "updates an existing contact with the same external_id (no duplicates)" do
      existing = create(:contact, source: "apollo", external_id: "6596ea42d05a3e00014cf630", email: "old@example.com", cohort: "old")

      http_double_with(response_double(code: 200, body: apollo_payload))

      expect {
        worker.perform(keyword, page, false)
      }.to change(Contact, :count).by(1)

      expect(existing.reload.cohort).to eq("vp marketing")
      expect(existing.email).to eq("email_not_unlocked@domain.com")
    end

    it "retries in 60s on 429 (rate limited)" do
      http_double_with(response_double(code: 429, body: {}))

      worker.perform(keyword, page, true)
      expect(described_class).to have_received(:perform_in)
        .with(60.seconds, keyword, page, true)
    end

    it "retries in 2 minutes on a 5xx" do
      http_double_with(response_double(code: 502, body: {}))

      worker.perform(keyword, page, false)
      expect(described_class).to have_received(:perform_in)
        .with(2.minutes, keyword, page, false)
    end

    it "logs and returns on unexpected status (e.g., 403) without scheduling or creating" do
      http_double_with(response_double(code: 403, body: { "error" => "forbidden" }))
      expect(Rails.logger).to receive(:error).with(/Unexpected response 403/)

      worker.perform(keyword, page, false)
      expect(Contact.count).to eq(0)
      expect(described_class).not_to have_received(:perform_in)
    end
  end
end