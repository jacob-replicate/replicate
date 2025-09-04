require "rails_helper"

describe EmailExtractor do
  subject(:extract) { described_class.call(input) }

  context "with nil" do
    let(:input) { nil }

    it "returns an empty array" do
      expect(extract).to eq([])
    end
  end

  context "with empty string" do
    let(:input) { "" }

    it "returns an empty array" do
      expect(extract).to eq([])
    end
  end

  context "with only whitespace" do
    let(:input) { "   \n   \t  " }

    it "returns an empty array" do
      expect(extract).to eq([])
    end
  end

  context "with various allowed delimiters" do
    let(:input) do
      <<~TXT
        alice@example.com, bob@example.com;carol@example.com
        dave@example.com eve@example.com
      TXT
    end

    it "splits on commas, semicolons, newlines, and spaces" do
      expect(extract).to eq([
        "alice@example.com",
        "bob@example.com",
        "carol@example.com",
        "dave@example.com",
        "eve@example.com"
      ])
    end
  end

  context "with extra internal whitespace" do
    let(:input) { "  alice@example.com   ;   bob@example.com  \n   carol@example.com  " }

    it "trims and normalizes tokens" do
      expect(extract).to eq([
        "alice@example.com",
        "bob@example.com",
        "carol@example.com"
      ])
    end
  end

  context "with hyphens in local or domain parts" do
    let(:input) { "jane-doe@my-company.org,team-leads@mail-server.com" }

    it "does not split on hyphens" do
      expect(extract).to eq([
        "jane-doe@my-company.org",
        "team-leads@mail-server.com"
      ])
    end
  end

  context "with invalid tokens mixed in" do
    let(:input) { "hello, not-an-email, ok@valid.com; also@valid.io world" }

    it "filters out non-email tokens using email regex" do
      expect(extract).to eq(["ok@valid.com", "also@valid.io"])
    end
  end

  context "with duplicates" do
    let(:input) do
      "dup@example.com, dup@example.com; DUP@example.com\n dup@example.com"
    end

    it "deduplicates exact matches and preserves first-occurrence order" do
      # Note: normalization (e.g., downcasing) is NOT applied by EmailExtractor.
      # Therefore, 'dup@example.com' and 'DUP@example.com' are distinct.
      expect(extract).to eq(["dup@example.com"])
    end
  end

  context "with tabs and mixed whitespace" do
    let(:input) { "a@example.com\tb@example.com   c@example.com\n\td@example.com" }

    it "handles tabs via squish + space splitting" do
      expect(extract).to match_array(%w[a@example.com b@example.com c@example.com d@example.com])
    end
  end

  context "with punctuation around emails" do
    let(:input) { "(alice@example.com), [bob@example.com]; <carol@example.com>" }

    it "keeps valid emails" do
      expect(extract).to match_array(["alice@example.com", "bob@example.com", "carol@example.com"])
    end
  end

  context "with emails adjacent to punctuation but separated by allowed delimiters" do
    let(:input) { "alice@example.com, (bob@example.com); carol@example.com" }

    it "keeps valid emails" do
      expect(extract).to match_array(["alice@example.com", "bob@example.com", "carol@example.com"])
    end
  end

  context "with realistic messy paste" do
    let(:input) do
      <<~TEXT
          Here are the contacts:
          alice@example.com; bob@example.com
          Carol <carol@example.com>, "Dave" <dave@example.com>
          not-an-email another-bad@ item
          eve@example.co.uk frank@sub.mail.example.com
        TEXT
    end

    it "returns only the valid emails and ignores surrounding text" do
      expect(extract).to match_array([
        "alice@example.com",
        "bob@example.com",
        "carol@example.com",
        "dave@example.com",
        "eve@example.co.uk",
        "frank@sub.mail.example.com"
      ])
    end
  end

  context "order preservation" do
    let(:input) { "x@example.com; a@example.com, m@example.com x@example.com a@example.com" }

    it "preserves order of first occurrences" do
      expect(extract).to eq(["x@example.com", "a@example.com", "m@example.com"])
    end
  end
end