require "rails_helper"

RSpec.describe Contact, type: :model do
  describe "associations" do
    it { should have_many(:conversations).dependent(:destroy) }
    it { should have_many(:messages).through(:conversations) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should allow_value("user@example.com").for(:email) }
    it { should_not allow_value("bad_email").for(:email) }

    it "requires name to have exactly two words" do
      invalid_contact = build(:contact, name: "Singleword", email: "valid@example.com")
      expect(invalid_contact).not_to be_valid
      expect(invalid_contact.errors[:name]).to include("must include at least first and last name")

      valid_contact = build(:contact, name: "Two Words", email: "valid@example.com")
      expect(valid_contact).to be_valid

      invalid_contact = build(:contact, name: "Three Words Here", email: "valid@example.com")
      expect(invalid_contact).to be_invalid
    end
  end

  describe "callbacks" do
    it "downcases email before save" do
      contact = create(:contact, email: "UPPERCASE@EXAMPLE.COM", name: "Jane Doe")
      expect(contact.reload.email).to eq("uppercase@example.com")
    end

    it "sets company_domain before save" do
      contact = create(:contact, email: "user@company.com", name: "John Doe")
      expect(contact.company_domain).to eq("company.com")
    end
  end

  describe "scopes" do
    let!(:contacted_contact)   { create(:contact, contacted: true) }
    let!(:uncontacted_contact) { create(:contact, contacted: false) }
    let!(:enriched_contact)    { create(:contact, email: "user@example.com") }
    let!(:unenriched_contact)  { create(:contact, email: "email_not_unlocked@domain.com") }

    it ".contacted returns only contacted" do
      expect(Contact.contacted).to include(contacted_contact)
      expect(Contact.contacted).not_to include(uncontacted_contact)
    end

    it ".enriched excludes nil and locked emails" do
      expect(Contact.enriched).to include(enriched_contact)
      expect(Contact.enriched).not_to include(unenriched_contact)
    end

    it ".unenriched includes locked emails" do
      nil_contact = create(:contact, email: "email_not_unlocked@domain.com")
      expect(Contact.unenriched).to include(unenriched_contact, nil_contact)
      expect(Contact.unenriched).not_to include(enriched_contact)
    end

    describe ".us scope" do
      it "includes contacts with a state in the US_STATES constant" do
        ny = create(:contact, state: "New York")
        ca = create(:contact, state: "California")
        tx = create(:contact, state: "Texas")

        results = Contact.us
        expect(results).to include(ny, ca, tx)
      end

      it "excludes contacts with states not in US_STATES" do
        on = create(:contact, state: "Ontario")
        bc = create(:contact, state: "British Columbia")
        mx = create(:contact, state: "Mexico City")

        results = Contact.us
        expect(results).not_to include(on, bc, mx)
      end

      it "handles DC variants defined in the constant" do
        dc1 = create(:contact, state: "District of Columbia")
        dc2 = create(:contact, state: "Washington DC")
        dc3 = create(:contact, state: "Washington, D.C.")

        results = Contact.us
        expect(results).to include(dc1, dc2, dc3)
      end

      it "returns empty when no contact has a state in US_STATES" do
        create(:contact, state: "Quebec")
        create(:contact, state: "Ontario")

        expect(Contact.us).to be_empty
      end
    end
  end

  describe "#first_name" do
    it "returns the first part of a two-word name" do
      contact = build(:contact, name: "John Smith", email: "john@example.com")
      expect(contact.first_name).to eq("John")
    end

    it "returns nil for names with fewer or more than two words" do
      expect(build(:contact, name: "Prince", email: "x@y.com").first_name).to be_nil
      expect(build(:contact, name: "John Ronald Reuel", email: "x@y.com").first_name).to be_nil
    end
  end

  describe "#passed_bounce_check?" do
    let(:contact) { build(:contact, email: "user@example.com", company_domain: "example.com") }

    before do
      # Don’t leak ENV changes across examples
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with("BOUNCER_API_KEY").and_return("test-key")
    end

    it "short-circuits on blocklist without making any HTTP call" do
      allow(contact).to receive(:company_domain_on_blocklist?).and_return(true)

      expect(Net::HTTP).not_to receive(:start)

      expect(contact.passed_bounce_check?).to be(false)
    end

    it "calls Net::HTTP.start and http.request with the right GET + headers; returns true on deliverable/accepted_email" do
      allow(contact).to receive(:company_domain_on_blocklist?).and_return(false)

      http_double = instance_double(Net::HTTP)
      response_double = instance_double(Net::HTTPResponse,
        body: { status: "deliverable", reason: "accepted_email" }.to_json
      )

      # Assert start is invoked with use_ssl and yields `http_double`, and returns the block's value
      expect(Net::HTTP).to receive(:start)
        .with("api.usebouncer.com", 443, use_ssl: true)
        .and_yield(http_double)
        .and_return(response_double)

      # Assert the request object and header are correct; return the fake response
      expect(http_double).to receive(:request) do |request|
        expect(request).to be_a(Net::HTTP::Get)
        expect(request["x-api-key"]).to eq("test-key")
        # Make sure the URL includes the email query param (no need to assert exact encoding)
        expect(request.uri.to_s).to include("email=user@example.com")
      end.and_return(response_double)

      expect(contact.passed_bounce_check?).to be(true)
    end

    it "returns false when status is deliverable but reason is not accepted_email" do
      allow(contact).to receive(:company_domain_on_blocklist?).and_return(false)

      http_double = instance_double(Net::HTTP)
      response_double = instance_double(Net::HTTPResponse,
        body: { status: "deliverable", reason: "catch_all" }.to_json
      )

      expect(Net::HTTP).to receive(:start)
        .with("api.usebouncer.com", 443, use_ssl: true)
        .and_yield(http_double)
        .and_return(response_double)

      expect(http_double).to receive(:request).and_return(response_double)

      expect(contact.passed_bounce_check?).to be(false)
    end

    it "returns false when status is not deliverable" do
      allow(contact).to receive(:company_domain_on_blocklist?).and_return(false)

      http_double = instance_double(Net::HTTP)
      response_double = instance_double(Net::HTTPResponse,
        body: { status: "undeliverable", reason: "rejected_email" }.to_json
      )

      expect(Net::HTTP).to receive(:start)
        .with("api.usebouncer.com", 443, use_ssl: true)
        .and_yield(http_double)
        .and_return(response_double)

      expect(http_double).to receive(:request).and_return(response_double)

      expect(contact.passed_bounce_check?).to be(false)
    end
  end

  describe "#metadata_for_gpt" do
    def build_contact_with(metadata_hash)
      build(:contact, name: "Test User", email: "test@example.com", metadata: metadata_hash)
    end

    let(:full_metadata_string_keys) do
      {
        "person_id" => "person-123",
        "id" => "id-should-be-ignored",
        "name" => "Ada Lovelace",
        "title" => "Principle Engineer", # intentionally misspelled to ensure passthrough
        "email" => "ada@analytical.engine",
        "present_raw_address" => "London, UK",
        "city" => "London",
        "state" => "London",
        "country" => "UK",
        "linkedin_url" => "https://linkedin.com/in/ada",
        "headline" => "Computing pioneer",
        "organization" => {
          "name" => "Analytical Engine Ltd",
          "primary_domain" => "analytical.engine",
          "linkedin_url" => "https://linkedin.com/company/ae",
          "angellist_url" => "https://angel.co/ae",
          "raw_address" => "1 Babbage St",
          "founded_year" => 1837,
          "organization_headcount_six_month_growth" => 12.3,
          "organization_headcount_twelve_month_growth" => 25.6
        },
        "employment_history" => [
          {
            "title" => "Engineer",
            "organization_name" => "AE",
            "start_date" => "1837-01-01",
            "end_date" => nil,
            "irrelevant" => "ignored"
          },
          {
            "title" => "Mathematician",
            "organization_name" => "Royal Society",
            "start_date" => "1835-01-01",
            "end_date" => "1836-12-31"
          }
        ],
        "extra_root_key" => "ignored"
      }
    end

    context "with complete metadata (string keys)" do
      it "returns a fully-populated, correctly-shaped hash" do
        contact = build_contact_with(full_metadata_string_keys)

        result = contact.metadata_for_gpt

        # top-level keys
        expect(result[:id]).to eq("person-123") # prefers person_id over id
        expect(result[:name]).to eq("Ada Lovelace")
        expect(result[:title]).to eq("Principle Engineer")
        expect(result[:email]).to eq("ada@analytical.engine")
        expect(result[:location]).to eq("London, UK") # uses present_raw_address
        expect(result[:linkedin]).to eq("https://linkedin.com/in/ada")
        expect(result[:headline]).to eq("Computing pioneer")

        # company hash
        expect(result[:company]).to eq(
          name: "Analytical Engine Ltd",
          domain: "analytical.engine",
          linkedin: "https://linkedin.com/company/ae",
          angellist: "https://angel.co/ae",
          hq_location: "1 Babbage St",
          founded_year: 1837,
          headcount_growth_6mo: 12.3,
          headcount_growth_12mo: 25.6
        )

        # employment_history array mapping
        expect(result[:employment_history]).to match_array([
          { title: "Engineer",      org: "AE",             start: "1837-01-01", end: nil },
          { title: "Mathematician", org: "Royal Society",  start: "1835-01-01", end: "1836-12-31" }
        ])

        # ensure only the defined keys are present at the top level
        expect(result.keys).to contain_exactly(
          :id, :name, :title, :email, :location, :linkedin, :headline, :company, :employment_history
        )
      end
    end

    context "id preference" do
      it "falls back to :id when :person_id is absent" do
        meta = full_metadata_string_keys.merge("person_id" => nil).merge("id" => "fallback-42")
        contact = build_contact_with(meta)

        expect(contact.metadata_for_gpt[:id]).to eq("fallback-42")
      end

      it "prefers :person_id when both are present" do
        contact = build_contact_with(full_metadata_string_keys)
        expect(contact.metadata_for_gpt[:id]).to eq("person-123")
      end
    end

    context "location construction" do
      it "builds location from city/state/country when present_raw_address is missing" do
        meta = full_metadata_string_keys.except("present_raw_address")
        contact = build_contact_with(meta)

        expect(contact.metadata_for_gpt[:location]).to eq("London, London, UK")
      end

      it "compacts missing city/state/country without stray commas" do
        meta = full_metadata_string_keys.except("present_raw_address").merge(
          "city" => "London", "state" => nil, "country" => "UK"
        )
        contact = build_contact_with(meta)

        expect(contact.metadata_for_gpt[:location]).to eq("London, UK")
      end

      it "returns empty string when no location components are available" do
        meta = full_metadata_string_keys.slice("organization").merge(
          "name" => "Ada Lovelace", "title" => "Engineer", "email" => "ada@x.y"
        )
        contact = build_contact_with(meta)

        expect(contact.metadata_for_gpt[:location]).to eq("")
      end
    end

    context "company section fallbacks" do
      it "returns nils for company fields when organization is missing" do
        meta = full_metadata_string_keys.except("organization")
        contact = build_contact_with(meta)

        expect(contact.metadata_for_gpt[:company]).to eq(
          name: nil,
          domain: nil,
          linkedin: nil,
          angellist: nil,
          hq_location: nil,
          founded_year: nil,
          headcount_growth_6mo: nil,
          headcount_growth_12mo: nil
        )
      end

      it "handles symbol keys just as well as string keys" do
        sym_meta = full_metadata_string_keys.deep_symbolize_keys
        contact = build_contact_with(sym_meta)

        expect(contact.metadata_for_gpt[:company][:domain]).to eq("analytical.engine")
      end
    end

    context "employment_history mapping" do
      it "returns [] when employment_history is nil" do
        meta = full_metadata_string_keys.merge("employment_history" => nil)
        contact = build_contact_with(meta)

        expect(contact.metadata_for_gpt[:employment_history]).to eq([])
      end

      it "maps only the specified fields (title, org, start, end) and ignores extras" do
        meta = {
          "employment_history" => [
            { "title" => "A", "organization_name" => "OrgA", "start_date" => "2020", "end_date" => "2021", "x" => "ignored" }
          ],
          "name" => "N", "email" => "e@e.com" # minimum for a valid build factory
        }
        contact = build_contact_with(meta)

        expect(contact.metadata_for_gpt[:employment_history]).to eq([
          { title: "A", org: "OrgA", start: "2020", end: "2021" }
        ])
      end
    end

    context "immutability" do
      it "does not mutate the original metadata hash" do
        meta = full_metadata_string_keys.deep_dup
        contact = build_contact_with(meta)

        _ = contact.metadata_for_gpt
        expect(contact.metadata).to eq(meta) # unchanged
      end
    end

    describe "#company_domain_on_blocklist?" do
      # Use a minimal contact and just set company_domain directly.
      # (No need to persist; the method only reads the attribute.)
      let(:contact) { build(:contact, email: "user@example.com", name: "Test User") }

      def blocked_for?(domain)
        contact.company_domain = domain
        contact.send(:company_domain_on_blocklist?)
      end

      it "blocks known companies and suffixes" do
        expect(blocked_for?("givecampus.com")).to be(true)     # "givecampus"
        expect(blocked_for?("replicate.info")).to be(true)     # "replicate"
        expect(blocked_for?("hashicorp.com")).to be(true)      # "hashicorp"
        expect(blocked_for?("university.edu")).to be(true)     # ".edu"
        expect(blocked_for?("army.mil")).to be(true)           # ".mil"
        expect(blocked_for?("agency.gov")).to be(true)         # ".gov"
        expect(blocked_for?("ibm.com")).to be(true)            # "ibm"
      end

      it "treats matches as substring (not just exact label or tld)" do
        expect(blocked_for?("research.ibm.cloud")).to be(true)     # contains "ibm"
        expect(blocked_for?("edge-replicate-services.net")).to be(true) # contains "replicate"
        expect(blocked_for?("x.y.gov.uk")).to be(true)             # contains ".gov"
      end

      it "does not block domains that only look similar (near-misses)" do
        expect(blocked_for?("education.com")).to be(false)   # does not contain ".edu"
        expect(blocked_for?("milestone.com")).to be(false)   # does not contain ".mil"
        expect(blocked_for?("governance.com")).to be(false)  # does not contain ".gov"
        expect(blocked_for?("example.com")).to be(false)
      end
    end
  end
end