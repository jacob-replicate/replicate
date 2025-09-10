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
    it "transforms raw metadata into structured hash" do
      raw_metadata = {
        "id" => "123",
        "name" => "Alice Example",
        "title" => "Engineer",
        "email" => "alice@example.com",
        "city" => "SF",
        "state" => "CA",
        "country" => "USA",
        "linkedin_url" => "http://linkedin.com/in/alice",
        "headline" => "Building things",
        "organization" => {
          "name" => "Acme Corp",
          "primary_domain" => "acme.com",
          "linkedin_url" => "http://linkedin.com/company/acme",
          "angellist_url" => "http://angel.co/acme",
          "raw_address" => "123 Street, SF",
          "founded_year" => 2000
        },
        "employment_history" => [
          { "title" => "Dev", "organization_name" => "Acme", "start_date" => "2020", "end_date" => "2022" }
        ]
      }

      contact = build(:contact, metadata: raw_metadata, name: "Alice Example", email: "alice@example.com")

      result = contact.metadata_for_gpt

      expect(result[:id]).to eq("123")
      expect(result[:company][:domain]).to eq("acme.com")
      expect(result[:employment_history].first[:title]).to eq("Dev")
    end
  end
end