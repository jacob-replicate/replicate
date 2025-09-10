require "rails_helper"

RSpec.describe ContactReport do
  describe ".call" do
    it "prints totals and per-score breakdown in descending score order" do
      # Create contacts with different scores and score reasons
      high_score_contact_with_reason =
        create(:contact, score: 10, score_reason: "matched senior criteria", email: "high1@example.com")

      high_score_contact_without_reason =
        create(:contact, score: 10, score_reason: nil, email: "high2@example.com")

      medium_score_contact = create(:contact, score: 5, score_reason: "matched mid-level criteria", email: "medium@example.com", contacted: true)

      expected_output = [
        "Total contacts: 3",
        "Scored: 2",
        "Unscored: 1",
        "",
        "Score 10: 2 contacts, 0 conversations",
        "Score 5: 1 contacts, 1 conversations"
      ].join("\n") + "\n"

      expect { described_class.call }.to output(expected_output).to_stdout
    end

    it "omits nil scores from the per-score section and still prints totals" do
      contact_with_nil_score =
        create(:contact, score: nil, score_reason: "ignored reason", email: "nil@example.com")

      contact_with_valid_score =
        create(:contact, score: 7, score_reason: nil, email: "valid@example.com")

      expected_output = [
        "Total contacts: 2",
        "Scored: 1",
        "Unscored: 1",
        "",
        "Score 7: 1 contacts, 0 conversations"
      ].join("\n") + "\n"

      expect { described_class.call }.to output(expected_output).to_stdout
    end
  end
end