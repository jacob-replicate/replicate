require "rails_helper"

RSpec.describe Organization, type: :model do
  include ActiveSupport::Testing::TimeHelpers

  describe "associations" do
    it { is_expected.to have_many(:members).dependent(:destroy) }
  end

  describe ".active" do
    around { |ex| travel_to(Time.zone.parse("2025-01-01 12:00:00")) { ex.run } }

    it "returns orgs with access_end_date in the future" do
      active_1  = create(:organization, access_end_date: 1.day.from_now)
      active_2  = create(:organization, access_end_date: 1.hour.from_now)
      expired   = create(:organization, access_end_date: 1.minute.ago)
      boundary  = create(:organization, access_end_date: Time.current)
      undated   = create(:organization, access_end_date: nil)

      result = described_class.active

      expect(result).to contain_exactly(active_1, active_2)
      expect(result).not_to include(expired, boundary, undated)
    end
  end

  describe "#active?" do
    around { |ex| travel_to(Time.zone.parse("2025-01-01 12:00:00")) { ex.run } }

    it "is true when access_end_date is in the future" do
      organization = build(:organization, access_end_date: 10.minutes.from_now)
      expect(organization.active?).to be(true)
    end

    it "is false when access_end_date is nil" do
      organization = build(:organization, access_end_date: nil)
      expect(organization.active?).to be(false)
    end

    it "is false when access_end_date is in the past" do
      organization = build(:organization, access_end_date: 5.minutes.ago)
      expect(organization.active?).to be(false)
    end

    it "is false on the exact boundary (== Time.current)" do
      organization = build(:organization, access_end_date: Time.current)
      expect(organization.active?).to be(false)
    end
  end

  describe "dependent: :destroy" do
    it "destroys members when the organization is destroyed" do
      organization = create(:organization)
      create_list(:member, 3, organization:)
      expect { organization.destroy }.to change { Member.count }.by(-3)
    end
  end
end