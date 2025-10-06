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

    # Stub every avatar row the service will attempt to strip out.
    # We return unique sentinel strings and then inject them into the raw input.
    let(:avatar_tokens) do
      {
        coach_first:        "TOKEN_COACH_FIRST",
        coach:              "TOKEN_COACH",
        brand_first:        "TOKEN_BRAND_FIRST",
        brand:              "TOKEN_BRAND",
        brand_overview:     "TOKEN_BRAND_OVERVIEW",
        brand_jacob:        "TOKEN_BRAND_JACOB",
        brand_replicate:    "TOKEN_BRAND_REPLICATE",
        student_taylor:     "TOKEN_STUDENT_TAYLOR",
        student_casey:      "TOKEN_STUDENT_CASEY",
        student_alex:       "TOKEN_STUDENT_ALEX"
      }
    end

    before do
      # coach avatars
      allow(AvatarService).to receive(:coach_avatar_row).with(first: true).and_return(avatar_tokens[:coach_first])
      allow(AvatarService).to receive(:coach_avatar_row).with(no_args).and_return(avatar_tokens[:coach])

      # brand avatars
      allow(AvatarService).to receive(:brand_avatar_row).with(first: true).and_return(avatar_tokens[:brand_first])
      allow(AvatarService).to receive(:brand_avatar_row).with(no_args).and_return(avatar_tokens[:brand])
      allow(AvatarService).to receive(:brand_avatar_row).with(name: "Overview").and_return(avatar_tokens[:brand_overview])
      allow(AvatarService).to receive(:brand_avatar_row).with(name: "Jacob Comer", first: true, photo_path: "jacob-square.jpg").and_return(avatar_tokens[:brand_jacob])
      allow(AvatarService).to receive(:brand_avatar_row).with(name: "replicate.info").and_return(avatar_tokens[:brand_replicate])

      # student avatars
      allow(AvatarService).to receive(:student_avatar_row).with("Taylor Morales").and_return(avatar_tokens[:student_taylor])
      allow(AvatarService).to receive(:student_avatar_row).with("Casey Patel").and_return(avatar_tokens[:student_casey])
      allow(AvatarService).to receive(:student_avatar_row).with("Alex Shaw").and_return(avatar_tokens[:student_alex])
    end

    it "removes all avatar rows that the AvatarService would render" do
      raw = <<~RAW
        #{avatar_tokens.values.join("\n")}
        Keep me
      RAW

      result = sanitize.clean(raw)

      avatar_tokens.values.each do |token|
        expect(result).not_to include(token)
      end
      expect(result).to include("Keep me")
    end

    it "normalizes greetings, code fences, smart quotes, apostrophes, asterisks, backticks, and removes <html> wrapper" do
      raw = <<~RAW
        <html>
        Hey Alex,
        Here is some ```html
        <b>“quoted” &amp; smart &#39;apos’</b> ``` with *stars* and `ticks`
        </html>
      RAW

      result = sanitize.clean(raw)

      aggregate_failures do
        # Greetings removed
        expect(result).not_to include("Hey Alex,")

        # code-fence & formatting chars removed
        expect(result).not_to include("```html")
        expect(result).not_to include("```")
        expect(result).not_to include("*")
        expect(result).not_to include("`")
        expect(result).not_to include("<html>")

        # smart quotes normalized, apostrophes normalized
        expect(result).not_to include("“")
        expect(result).not_to include("”")
        expect(result).not_to include("’")
        expect(result).not_to include("&#39;")
        expect(result).to include('"quoted"')
        expect(result).to include("apos'")
        expect(result).not_to include("<b class='font-medium'>")
      end
    end

    it "removes newlines early and squishes whitespace" do
      raw = "Line 1\n\nLine   2\nLine 3"
      result = sanitize.clean(raw)
      expect(result).to eq("Line 1Line 2Line 3")
    end

    it "removes specific greetings for Taylor and Casey as well" do
      result = sanitize.clean("Hey Taylor, Hey Casey, content")
      expect(result).to eq("content".html_safe)
    end

    it "is idempotent under repeated cleaning (second pass doesn't re-damage output)" do
      once  = sanitize.clean(%q{<b>Bold “text”</b> and <i>plain</i>})
      twice = sanitize.clean(once.dup)
      expect(twice).to eq(once)
    end

    it "does not crash on empty input and returns empty SafeBuffer" do
      result = sanitize.clean("")
      expect(result).to eq("".html_safe)
      expect(result.html_safe?).to be(true)
    end
  end
end