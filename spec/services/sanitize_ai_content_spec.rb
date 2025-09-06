require "rails_helper"

RSpec.describe SanitizeAiContent do
  describe ".call" do
    let(:raw_input) do
      <<~HTML
        <html>
        Hey Alex,
        <b>Welcome</b> to <b>replicate.info</b>!<br>
        #{AvatarService.coach_avatar_row}
        #{AvatarService.brand_avatar_row(name: "replicate.info")}
        #{AvatarService.student_avatar_row("Alex Shaw")}
        #{AvatarService.student_avatar_row("Casey Patel")}
        #{AvatarService.student_avatar_row("Taylor Morales")}
        Some <b>bold</b> text, some *markdown*, and
        some `code`. “Smart quotes” and &#39;HTML quotes&#39;.
        ```html
        <div>bad content</div>
        ```
        <b>One more</b>
      HTML
    end

    it "removes all known avatar rows" do
      result = described_class.call(raw_input)
      expect(result).not_to include(AvatarService.coach_avatar_row)
      expect(result).not_to include(AvatarService.brand_avatar_row(name: "replicate.info"))
      expect(result).not_to include(AvatarService.student_avatar_row("Taylor Morales"))
      expect(result).not_to include(AvatarService.student_avatar_row("Casey Patel"))
      expect(result).not_to include(AvatarService.student_avatar_row("Alex Shaw"))
    end

    it "removes greeting lines" do
      expect(described_class.call("Hey Alex, blah")).not_to include("Hey Alex")
      expect(described_class.call("Hey Taylor, blah")).not_to include("Hey Taylor")
      expect(described_class.call("Hey Casey, blah")).not_to include("Hey Casey")
    end

    it "removes all HTML tags but preserves bold intent" do
      result = described_class.call(raw_input)
      expect(result).not_to include("<html>")
      expect(result).not_to include("<div>")
      expect(result).to include("<b class='font-medium'>Welcome</b>")
    end

    it "replaces newlines with compacted <br/> and strips excessive breaks" do
      input = "Line1\n\n\nLine2\nLine3"
      result = described_class.call(input)
      expect(result).not_to match(/^<br\/>+/)
      expect(result).not_to match(/<br\/>+$/)
      expect(result).to include("Line1<br/>Line2Line3")
    end

    it "cleans up quotes and markdown artifacts" do
      input = "“smart” &#39;quotes&#39; *bold* `code`"
      result = described_class.call(input)
      expect(result).to include("\"smart\"")
      expect(result).to include("'quotes'")
      expect(result).not_to include("*bold*")
      expect(result).not_to include("`code`")
    end

    it "cleans up triple backtick blocks" do
      input = "```html\n<div>something</div>\n```"
      result = described_class.call(input)
      expect(result).not_to include("```")
      expect(result).not_to include("<div>")
    end

    it "collapses multiple spaces and trims the result" do
      input = "<b>   Hello   </b>   world   \n\n  !   "
      result = described_class.call(input)
      expect(result).to eq("<b class='font-medium'>Hello</b>world!".html_safe)
    end

    it "returns html_safe string" do
      result = described_class.call("<b>Hi</b>")
      expect(result).to be_html_safe
    end
  end
end