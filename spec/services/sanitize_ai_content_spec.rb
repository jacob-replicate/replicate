require "rails_helper"

RSpec.describe SanitizeAiContent do
  describe ".call" do
    it "delegates to #clean and returns the sanitized string" do
      raw = "Hello <b>world</b>"
      expect(described_class.call(raw)).to eq("Hello world")
    end
  end

  describe "#clean" do
    subject(:sanitize) { described_class.new }

    it "removes avatar rows that the AvatarService would render" do
      coach_avatar = AvatarService.coach_avatar_row
      jacob_avatar = AvatarService.jacob_avatar_row
      summary_avatar = AvatarService.avatar_row(name: "Incident Summary")

      raw = "#{coach_avatar}#{jacob_avatar}#{summary_avatar}Keep me"

      result = sanitize.clean(raw)

      expect(result).not_to include(coach_avatar)
      expect(result).not_to include(jacob_avatar)
      expect(result).not_to include(summary_avatar)
      expect(result).to include("Keep me")
    end

    it "normalizes code fences, smart quotes, apostrophes, asterisks, and backticks" do
      raw = <<~RAW
        <html>
        Here is some ```html
        <b>"quoted" &amp; smart &#39;apos'</b> ``` with *stars* and `ticks`
      RAW

      result = sanitize.clean(raw)

      aggregate_failures do
        # code-fence & formatting chars removed
        expect(result).not_to include("```html")
        expect(result).not_to include("```")
        expect(result).not_to include("*")
        expect(result).not_to include("`")
        expect(result).not_to include("<html>")

        # smart quotes normalized, &#39; converted to apostrophe
        expect(result).not_to include(""")
        expect(result).not_to include(""")
        expect(result).not_to include("&#39;")
        expect(result).to include('"quoted"')
        expect(result).to include("'apos'")
      end
    end

    it "removes newlines and squishes whitespace" do
      raw = "Line 1\n\nLine   2\nLine 3"
      result = sanitize.clean(raw)
      expect(result).to eq("Line 1Line 2Line 3")
    end

    it "removes bold tags" do
      result = sanitize.clean("<b>Bold text</b>")
      expect(result).to eq("Bold text")
    end

    it "removes hint links" do
      raw = "Content #{HINT_LINK} more content"
      result = sanitize.clean(raw)
      expect(result).not_to include("hint")
    end

    it "is idempotent under repeated cleaning (second pass doesn't re-damage output)" do
      once  = sanitize.clean(%q{<b>Bold "text"</b> and plain})
      twice = sanitize.clean(once.dup)
      expect(twice).to eq(once)
    end

    it "does not crash on empty input and returns empty SafeBuffer" do
      result = sanitize.clean("")
      expect(result).to eq("".html_safe)
      expect(result.html_safe?).to be(true)
    end

    it "removes script tags" do
      raw = "Before<script>alert('xss')</script>After"
      result = sanitize.clean(raw)
      expect(result).not_to include("script")
      expect(result).not_to include("alert")
      expect(result).to include("Before")
      expect(result).to include("After")
    end
  end
end