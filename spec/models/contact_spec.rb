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
    let(:contact) { build(:contact, email: "test@example.com", company_domain: "example.com", name: "Jane Doe") }

    it "returns false if domain is blocklisted" do
      blocked = build(:contact, email: "foo@givecampus.com", company_domain: "givecampus.com", name: "Joe Doe")
      expect(blocked.passed_bounce_check?).to eq(false)
    end

    it "returns true when API says deliverable" do
      fake_response = instance_double(Net::HTTPOK, body: { status: "deliverable", reason: "accepted_email" }.to_json)
      allow(Net::HTTP).to receive(:start).and_return(fake_response)

      expect(contact.passed_bounce_check?).to eq(true)
    end

    it "returns false when API says undeliverable" do
      fake_response = instance_double(Net::HTTPOK, body: { status: "undeliverable", reason: "rejected" }.to_json)
      allow(Net::HTTP).to receive(:start).and_return(fake_response)

      expect(contact.passed_bounce_check?).to eq(false)
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
  end
end