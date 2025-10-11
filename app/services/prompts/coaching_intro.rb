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
      return "Sentence exceeds 30 words: #{long_sentence(llm_output)}" if long_sentence(llm_output)
      return "Redundant sentences detected" if redundant_sentences?(llm_output)

      nil
    end

    def contains?(text, patterns)
      patterns.any? { |r| text =~ r }
    end

    def long_sentence(text)
      text.strip.split(/(?<=[.!?])\s+/).find do |s|
        s.split.size > 30 && !s.strip.end_with?("?")
      end
    end

    def redundant_sentences?(text)
      sentences = text.strip.scan(/[^.!?]+[.!?]/).map(&:strip).map { |s| normalize(s) }
      return false if sentences.size < 2

      sentences.combination(2).any? do |a, b|
        a.include?(b) || b.include?(a)
      end
    end

    def normalize(sentence)
      sentence.downcase.gsub(/\W/, "")
    end

    def nonempty_lines(text)
      text.strip.lines.map(&:strip).reject(&:empty?)
    end
  end
end