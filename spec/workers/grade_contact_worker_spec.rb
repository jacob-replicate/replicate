require "rails_helper"

RSpec.describe GradeContactWorker, type: :worker do
  let(:metadata_raw) { { "team_size" => "20", "stack" => { "cloud" => "aws" } } }
  let!(:contact) { create(:contact, metadata: metadata_raw, score: nil, score_reason: nil) }

  def prompt_double(payload)
    instance_double("Prompts::LeadScoring", call: payload)
  end

  describe "#perform" do
    it "returns quietly when contact is missing" do
      expect(Prompts::LeadScoring).not_to receive(:new)
      expect {
        described_class.new.perform(-999)
      }.not_to raise_error
    end

    it "does nothing when a positive score already exists and force is false" do
      contact.update!(score: 80, score_reason: "already graded")

      expect(Prompts::LeadScoring).not_to receive(:new)

      described_class.new.perform(contact.id, false)

      expect(contact.reload.score).to eq(80)
      expect(contact.reload.score_reason).to eq("already graded")
    end

    it "re-scores when force is true even if a positive score exists" do
      contact.update!(score: 80, score_reason: "old")

      expected_context = {
        context: {
          lead_metadata: { team_size: "20", stack: { cloud: "aws" } } # deep_symbolize_keys
        }
      }

      scoring = prompt_double({ "score" => 92, "reason" => "high intent" })
      expect(Prompts::LeadScoring).to receive(:new).with(expected_context).and_return(scoring)

      described_class.new.perform(contact.id, true)

      contact.reload
      expect(contact.score).to eq(92)
      expect(contact.score_reason).to eq("high intent")
    end

    it "grades a fresh contact and saves score + reason" do
      expected_context = {
        context: {
          lead_metadata: { team_size: "20", stack: { cloud: "aws" } }
        }
      }

      scoring = prompt_double({ "score" => 100, "reason" => "perfect match" })
      expect(Prompts::LeadScoring).to receive(:new).with(expected_context).and_return(scoring)

      described_class.new.perform(contact.id)

      contact.reload
      expect(contact.score).to eq(100)
      expect(contact.score_reason).to eq("perfect match")
    end

    it "stores nil for score_reason when the prompt returns a blank reason" do
      scoring = prompt_double({ "score" => 55, "reason" => "" })
      allow(Prompts::LeadScoring).to receive(:new).and_return(scoring)

      described_class.new.perform(contact.id)

      expect(contact.reload.score).to eq(55)
      expect(contact.reload.score_reason).to be_nil
    end
  end
end