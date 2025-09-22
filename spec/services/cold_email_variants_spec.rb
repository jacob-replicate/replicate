# spec/services/cold_email_variants_spec.rb
require "rails_helper"

RSpec.describe ColdEmailVariants do
  describe ".count" do
    it "equals the product of option set sizes" do
      expect(described_class.count).to eq(described_class.subjects.count * described_class.intros.count * described_class.tech_explanation.count * described_class.ctas.count)
    end
  end

  describe ".build" do
    let(:contact) { create(:contact, name: "Jacob Comer") }
    let(:inbox)   { INBOXES.first }

    it "returns a subject from the subjects list" do
      result = described_class.build(inbox:, contact:)
      expect(described_class.subjects).to include(result["subject"])
    end

    it "renders greeting, one intro, one tech_explanation, one cta, signature, and footer" do
      result = described_class.build(inbox:, contact:)
      body = result["body_html"]

      expect(body).to include("<p>Hi #{contact.first_name},</p>")
      expect(described_class.intros.any? { |s| body.include?(s) }).to be(true)
      expect(described_class.tech_explanation.any? { |s| body.include?(s) }).to be(true)
      expect(described_class.ctas.any? { |s| body.include?(s) }).to be(true)
      expect(body).to include(inbox["signature"])
      expect(body).to include("https://replicate.info/contacts/#{contact.id}/unsubscribe")
      expect(body).to include("<p style=\"font-size: 80%; opacity: 0.6\">")
      expect(body).to start_with("<p>")
      expect(body).to end_with("\n")
    end

    it "wraps each segment in paragraph tags" do
      result = described_class.build(inbox:, contact:)
      body = result["body_html"]
      expect(body.scan(%r{<p>}).size).to eq(5) # One less for unsubscribe styling
      expect(body.scan(%r{</p>}).size).to eq(6)
    end

    context "with deterministic single-choice sets" do
      before do
        allow(described_class).to receive(:subjects).and_return(["SUBJ"])
        allow(described_class).to receive(:intros).and_return(["INTRO <a href='https://replicate.info'>replicate.info</a>"])
        allow(described_class).to receive(:tech_explanation).and_return(["TECH"])
        allow(described_class).to receive(:ctas).and_return(["CTA"])
      end

      it "produces exact HTML with the chosen elements" do
        result = described_class.build(inbox:, contact:)
        expect(result["subject"]).to eq("SUBJ")

        expected_html = <<~HTML
          <p>Hi #{contact.first_name},</p>
          <p>INTRO <a href='https://replicate.info'>replicate.info</a></p>
          <p>TECH</p>
          <p>CTA</p>
          <p>Best,<br/>J.C.</p>
          <p style="font-size: 80%; opacity: 0.6">Replicate Software, LLC - 131 Continental Dr, Suite 305, Newark, DE - <a href='https://replicate.info/contacts/#{contact.id}/unsubscribe'>Unsubscribe</a></p>
        HTML

        expect(result["body_html"]).to eq(expected_html)
      end
    end
  end

  describe ".subjects" do
    it "is non-empty and contains strings" do
      expect(described_class.subjects).to be_present
      expect(described_class.subjects).to all(be_a(String))
    end
  end

  describe ".intros" do
    it "is non-empty and contains the replicate.info link" do
      expect(described_class.intros).to be_present
      expect(described_class.intros.any? { |s| s.include?("https://replicate.info") }).to be(true)
    end
  end

  describe ".tech_explanation" do
    it "is non-empty and references weekly or monday concept" do
      expect(described_class.tech_explanation).to be_present
      expect(described_class.tech_explanation.join(" ").downcase).to match(/week|monday/)
    end
  end

  describe ".ctas" do
    it "is non-empty and contains concise statements" do
      expect(described_class.ctas).to be_present
      expect(described_class.ctas).to all(be_a(String))
      expect(described_class.ctas.map(&:length).max).to be < 200
    end
  end
end