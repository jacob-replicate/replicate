require "rails_helper"

RSpec.describe ColdEmailScheduler do
  include ActiveSupport::Testing::TimeHelpers

  before do
    allow(Holidays).to receive(:on).and_return([]) # not a holiday unless overridden
    allow(ColdEmailVariants).to receive(:build).and_return({"subject"=>"s","body_html"=>"b"})
    allow(SendColdEmailWorker).to receive(:perform_at)
  end

  before(:each) do
    srand(12345)
  end

  # Helpers for inspecting the per-hour distribution
  def max_per_hour(per_hour)
    per_hour.values.map { |by_hour| by_hour.values.map(&:size).max || 0 }.max || 0
  end

  describe "initializer gating (weekday/holiday/dev)" do
    it "does not initialize on weekends or holidays (unless in development)" do
      allow_any_instance_of(Contact).to receive(:passed_bounce_check?).and_return(true)

      Time.use_zone("America/New_York") do
        travel_to Time.zone.parse("2025-03-15 10:00:00") do # Saturday
          sched = described_class.new(min_score: 5)
          # initialize returned early — ivars are not set
          expect(sched.instance_variable_get(:@contacts)).to be_nil
        end
      end

      allow(Holidays).to receive(:on).and_return([{name: "Fake US Holiday", regions: [:us]}])
      Time.use_zone("America/New_York") do
        travel_to Time.zone.parse("2025-03-12 10:00:00") do # Wednesday
          sched = described_class.new(min_score: 5)
          expect(sched.instance_variable_get(:@contacts)).to be_nil
        end
      end
    end

    it "initializes in development even if not a run day" do
      allow_any_instance_of(Contact).to receive(:passed_bounce_check?).and_return(true)
      allow(Rails).to receive_message_chain(:env, :development?).and_return(true)
      allow_any_instance_of(Contact).to receive(:passed_bounce_check?).and_return(true)

      create(:contact, score: 50)

      Time.use_zone("America/New_York") do
        travel_to Time.zone.parse("2025-03-16 10:00:00") do # Sunday
          sched = described_class.new(min_score: 5)
          expect(sched.instance_variable_get(:@contacts)).to be_present
        end
      end
    end
  end

  describe "#build_send_times" do
    it "generates sorted times only within SEND_HOURS with fixed spacing and count" do
      Timecop.freeze Time.zone.parse("2025-03-12 10:00:00") do
        allow_any_instance_of(Contact).to receive(:passed_bounce_check?).and_return(true)

        sched = described_class.new(min_score: 0)
        times = sched.instance_variable_get(:@send_times)
        expect(times).to eq(times.sort)
        expect(times.size).to eq(described_class::MAX_PER_HOUR * INBOXES.size * described_class::SEND_HOURS.size)
        expect(times.map(&:hour).uniq).to match_array(ColdEmailScheduler::SEND_HOURS)
        expect(times.select { |t| t.hour == 11 }.map(&:min)).to eq([2, 21, 49])
        expect(times.select { |t| t.hour == 11 }.map(&:sec)).to eq([37, 36, 37])
      end
    end
  end

  describe "#call scheduling" do
    before do
      allow(Holidays).to receive(:on).and_return([]) # weekday, not holiday
      Time.use_zone("America/New_York") do
        travel_to Time.zone.parse("2025-03-12 10:00:00") do
          # time is fixed for all examples in this group
        end
      end
    end

    it "returns immediately when there are no eligible contacts" do
      Timecop.freeze Time.zone.parse("2025-03-12 10:00:00") do
        allow_any_instance_of(Contact).to receive(:passed_bounce_check?).and_return(true)
        create(:contact, score: 1) # min_score 100 excludes
        sched = described_class.new(min_score: 100)

        expect(SendColdEmailWorker).not_to have_received(:perform_at)
        expect(sched.call).to be_nil
      end
    end

    it "never emails people from the same company domain within the same 30 days" do
      allow_any_instance_of(Contact).to receive(:passed_bounce_check?).and_return(true)

      Timecop.freeze Time.zone.parse("2025-03-12 10:00:00") do
        jacob = create(:contact, score: 100, email: "jacob@acme.com", contacted_at: 15.days.ago)
        jane = create(:contact, score: 100, email: "jane@acme.com", contacted_at: nil)
        larry = create(:contact, score: 100, email: "larry@acme.com", contacted_at: nil)

        bob = create(:contact, score: 100, email: "bob@initech.com", contacted_at: 40.days.ago)
        mary = create(:contact, score: 100, email: "jane@initech.com", contacted_at: nil)

        susie = create(:contact, score: 100, email: "susie@company.com", contacted_at: nil)

        scheduled = []
        allow(SendColdEmailWorker).to receive(:perform_at) do |_t, id, _inbox, _variant|
          scheduled << id
        end

        described_class.new(min_score: 0).call

        expect(scheduled).to match_array([mary.id, susie.id])
      end
    end

    it "never breaks the daily/hourly limits" do
      allow_any_instance_of(Contact).to receive(:passed_bounce_check?).and_return(true)

      # 90 > daily total capacity (81) to ensure we hit limits
      contacts = 90.times.map { |i| create(:contact, score: 100 - i) }

      per_hour = nil
      Time.use_zone("America/New_York") do
        travel_to Time.zone.parse("2025-03-12 10:00:00") do
          sched = described_class.new(min_score: 0)
          per_hour = sched.call
        end
      end

      expect(SendColdEmailWorker).to have_received(:perform_at).exactly(described_class::MAX_PER_HOUR * INBOXES.size * described_class::SEND_HOURS.size).times

      # No hour for any inbox exceeds 3
      per_hour.each do |email, by_hour|
        by_hour.each do |hour, rows|
          expect(rows.size).to be > 0
          expect(rows.size).to be <= described_class::MAX_PER_HOUR
        end

        total_for_inbox = by_hour.values.sum(&:size)
        expect(total_for_inbox).to be <= described_class::MAX_MESSAGES_PER_DAY
      end
    end

    it "only pulls US + enriched + not queued + not contacted + min_score and in score-desc order" do
      allow_any_instance_of(Contact).to receive(:passed_bounce_check?).and_return(true)

      # Eligible
      c1 = create(:contact, email: "a@x.com", state: "California", score: 50)
      c2 = create(:contact, email: "b@y.com", state: "Texas", score: 75)
      c3 = create(:contact, email: "c@z.com", state: "New York", score: 60)

      # Ineligible for various reasons
      create(:contact, email: "blocked@x.com", state: "Ontario", score: 90)               # non-US
      create(:contact, state: "California", email: "email_not_unlocked@domain.com")         # unenriched
      create(:contact, email: "queued@x.com", state: "California", email_queued_at: Time.current)
      create(:contact, email: "contacted@a.com", state: "California", contacted_at: Time.now)
      create(:contact, email: "low@x.com", state: "California", score: 4)                  # below min

      # min score 50 => expect ordering by score: c2 (75), c3 (60), c1 (50)
      scheduled = []
      allow(SendColdEmailWorker).to receive(:perform_at) do |_t, id, _inbox, _variant|
        scheduled << id
      end

      Timecop.freeze Time.zone.parse("2025-03-12 10:00:00") do
        sched = described_class.new(min_score: 50)
        sched.call
      end

      expect(scheduled).to eq([c2.id, c3.id, c1.id])
      # ensure none of the ineligible ones were scheduled
      expect(scheduled.size).to eq(3)
    end

    it "skips a contact that fails the bounce check and flips its score negative + nulls email" do
      fail = create(:contact, email: "bad@x.com", score: 40)

      allow_any_instance_of(Contact).to receive(:passed_bounce_check?).and_return(false)

      scheduled_ids = []
      allow(SendColdEmailWorker).to receive(:perform_at) do |_t, id, _inbox, _variant|
        scheduled_ids << id
      end

      Time.use_zone("America/New_York") do
        travel_to Time.zone.parse("2025-03-12 10:00:00") do
          sched = described_class.new(min_score: 0)
          sched.call
        end
      end

      expect(scheduled_ids).to eq([])
      expect(fail.reload.email).to be_nil
      expect(fail.score).to eq(-40)
    end

    it "returns the per-hour allocation hash with inbox/email, hour keys, and rows that include the variant" do
      allow_any_instance_of(Contact).to receive(:passed_bounce_check?).and_return(true)
      c = create(:contact, email: "ok@x.com", score: 80)

      per_hour = nil
      Time.use_zone("America/New_York") do
        travel_to Time.zone.parse("2025-03-12 10:00:00") do
          sched = described_class.new(min_score: 0)
          per_hour = sched.call
        end
      end

      # Should have placed exactly one email
      total_rows = per_hour.values.sum { |by_hour| by_hour.values.sum(&:size) }
      expect(total_rows).to eq(1)

      # And each row is [from_name, email, time, contact_id, contact_name, contact_email, variant]
      row = per_hour.values.flat_map(&:values).flatten(1).first
      expect(row[0]).to be_a(String) # from_name
      expect(row[1]).to match(/@/)   # inbox email
      expect(row[2]).to be_a(Time)
      expect(row[3]).to eq(c.id)
      expect(row[4]).to eq(c.name)
      expect(row[5]).to eq(c.email)
      expect(row[6]).to eq({"subject"=>"s", "body_html"=>"b"})
    end
  end
end