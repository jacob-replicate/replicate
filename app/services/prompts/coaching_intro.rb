module Prompts
  class CoachingIntro < Prompts::Base
    UI_NOUNS = %w[
      spinner button dropdown list summary form field tab ticket page label log user users
    ].freeze

    METAPHOR_PATTERNS = [
      /\blike\b/i,
      /\bas if\b/i,
      /\bas though\b/i,
      /\bfeels like\b/i,
      /\bcatching a glimpse\b/i,
      /\bfrozen in time\b/i,
      /\bwaiting for something that never comes\b/i,
      /\bsits there\b/i,
      /\bseems content\b/i,
      /\bstays frozen\b/i,
      /\bstays that way\b/i
    ].freeze

    INTERPRETIVE_PHRASES = [
      /\bseems to\b/i,
      /\bshould\b/i,
      /\btrying to\b/i,
      /\brefuses\b/i,
      /\bexpected\b/i,
      /\bwants to\b/i,
      /\bconfused\b/i,
      /\backnowledge\b/i,
      /\bappears to\b/i
    ].freeze

    SOFT_LANGUAGE = [
      /\bnoticeable (enough )?to\b/i,
      /\bmake(s)? you wonder\b/i,
      /\bit's just\b/i,
      /\ba(n)? extra (beat|moment|second)\b/i,
      /\bhang(s)? (in the air|back)\b/i,
      /\bslight\b/i,
      /\bit (feels|seems|looks) (like|as if)?\b/i
    ].freeze


    def call
      intro_paragraph = fetch_valid_response
      return "" if intro_paragraph.nil?

      classes = (@conversation.present? && @conversation.web?) ? " class='font-medium'" : ""
      intro_paragraph + "<p><b#{classes}>#{questions.sample}</b></p>".html_safe
    end

    private

    def questions
      [
        "Where would you look first?",
        "What is the first thing you'd check?",
        "What would you poke at first?",
        "What would you want to rule out early?",
        "What's going through your mind here?",
        "How do we get back to green?",
        "What's your first move here?",
        "What would you dig into first?",
        "Where's the first place you'd start digging?"
      ]
    end

    def validate(llm_output)
      lines = nonempty_lines(llm_output)

      return "First line must start with 'Imagine'" unless lines.first.start_with?("Imagine")
      return "Metaphor or personification detected" if contains?(llm_output, METAPHOR_PATTERNS)
      return "Interpretive language detected" if contains?(llm_output, INTERPRETIVE_PHRASES)
      return "Soft or narrative phrasing detected" if contains?(llm_output, SOFT_LANGUAGE)

      nil
    end

    def contains?(text, patterns)
      patterns.any? { |r| text =~ r }
    end

    def normalize(sentence)
      sentence.downcase.gsub(/\W/, "")
    end

    def nonempty_lines(text)
      text.strip.lines.map(&:strip).reject(&:empty?)
    end
  end
end