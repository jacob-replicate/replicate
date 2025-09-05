# spec/models/member_spec.rb
require "rails_helper"

RSpec.describe Member, type: :model do
  describe "associations" do
    it { should belong_to(:organization) }
    it { should have_many(:conversations).dependent(:destroy) }
  end

  describe "constants" do
    it "defines ROLES as owner and engineer" do
      expect(Member::ROLES).to match_array(%w[owner engineer])
    end
  end

  describe "validations" do
    subject { create(:member) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_presence_of(:role) }
    it { should validate_inclusion_of(:role).in_array(Member::ROLES) }
  end

  describe "scopes" do
    describe ".subscribed" do
      it "returns only subscribed members" do
        member1 = create(:member, subscribed: true)
        member2 = create(:member, subscribed: false)
        member3 = create(:member, subscribed: true)
        expect(Member.subscribed).to match_array([member1, member3])
      end
    end
  end

  describe "role helpers" do
    it "#owner? is true only for role 'owner'" do
      member = build(:member, role: "owner")
      expect(member.owner?).to be(true)
      member = build(:member, role: "engineer")
      expect(member.owner?).to be(false)
    end

    it "#engineer? is true only for role 'engineer'" do
      member = build(:member, role: "engineer")
      expect(member.engineer?).to be(true)
      member = build(:member, role: "owner")
      expect(member.engineer?).to be(false)
    end
  end

  describe "callbacks: set_email_domain" do
    context "on create" do
      it "derives a normalized domain" do
        member = build(:member, email: "  Foo.Bar+xyz@Sub.Example.Co.UK  ", email_domain: nil)
        expect { member.valid? }.to change { member.email_domain }.from(nil).to("sub.example.co.uk")
      end

      it "downcases and strips unwanted characters" do
        member = build(:member, email: "user@.._ACME-Cloud!.COM.. ")
        expect { member.valid? }.to change { member.email_domain }.to("_acme-cloud.com")
      end

      it "sets email_domain to nil for blank email" do
        member = build(:member, email: "")
        member.valid?
        expect(member.email_domain).to be_nil
      end

      it "sets email_domain to nil when domain has no dot" do
        member = build(:member, email: "dev@localhost")
        member.valid?
        expect(member.email_domain).to be_nil
      end

      it "takes the last segment if multiple @ signs exist" do
        member = build(:member, email: "a@b@c.COM")
        member.valid?
        expect(member.email_domain).to eq("c.com")
      end
    end

    context "on update" do
      let!(:member) { create(:member, email: "user@old.example.com") }

      it "updates email_domain when email changes" do
        expect(member.email_domain).to eq("old.example.com")
        member.update!(email: "New_User@Example.ORG")
        expect(member.email_domain).to eq("example.org")
      end

      it "does not recompute when email does not change" do
        original = member.email_domain
        member.update!(role: member.role)
        expect(member.email_domain).to eq(original)
      end
    end
  end

  describe "sanitization edge cases" do
    it "removes non-ASCII characters" do
      member = build(:member, email: "u@exámple.cöm!? ")
      member.valid?
      expect(member.email_domain).to eq("exmple.cm")
    end

    it "preserves underscores, hyphens, and dots" do
      member = build(:member, email: "x@._foo-bar..baz_.com.")
      member.valid?
      expect(member.email_domain).to eq("_foo-bar..baz_.com")
    end
  end
end