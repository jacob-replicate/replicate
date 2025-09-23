require "rails_helper"

RSpec.describe EnrichContactScheduler, type: :service do
  describe ".call" do
    let!(:unenriched_contact) do
      create(:contact,
        email: "email_not_unlocked@domain.com",
        score: 90,
        external_id: "abc123"
      )
    end

    let!(:unenriched_contact_two) do
      create(:contact,
        email: "email_not_unlocked@domain.com",
        score: 95,
        external_id: "abc1234"
      )
    end

    let!(:unenriched_contact_to_ignore) do
      create(:contact,
        email: "email_not_unlocked@domain.com",
        score: 80, # under threshold
        external_id: "abc123"
      )
    end

    let!(:enriched_contact) do
      create(:contact,
        email: "real@example.com",
        score: 90,
        external_id: "xyz789"
      )
    end

    it "schedules jobs only for unenriched contacts (with @domain.com placeholder)" do
      expect {
        described_class.call(limit: 10)
      }.to change(EnrichContactsWorker.jobs, :size).by(1)

      job = EnrichContactsWorker.jobs.last
      expect(job["args"].first).to eq([unenriched_contact_two.id, unenriched_contact.id])
      expect(job["args"].first).not_to include(enriched_contact.id)
    end

    it "respects the limit argument" do
      create_list(:contact, 15, email: "email_not_unlocked@domain.com", score: 100, external_id: "id-#{SecureRandom.hex(4)}")

      expect {
        described_class.call(limit: 20)
      }.to change(EnrichContactsWorker.jobs, :size).by(2) # 20 IDs -> 2 batches
    end

    it "schedules batches in 30s increments" do
      Timecop.freeze do
        batch = create_list(:contact, 20,
          email: "email_not_unlocked@domain.com",
          score: 100,
          external_id: -> { SecureRandom.uuid }
        )

        described_class.call(limit: 20)

        jobs = EnrichContactsWorker.jobs
        expect(jobs.size).to eq(2)

        first_at  = jobs[0]["at"]
        second_at = jobs[1]["at"]

        expect(Time.at(jobs[1]["at"]).change(usec: 0)).to eq((Time.current + 30.seconds).change(usec: 0))
      end
    end
  end
end