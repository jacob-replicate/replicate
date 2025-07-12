module Prompts
  class CoachingIntro
    RETRY_COUNT = 10

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

    TRANSITIONS_OR_CONJUNCTIONS = [
      /\bbut\b/i,
      /\band\b/i,
      /\bwhile\b/i,
      /\bso\b/i,
      /\beven though\b/i,
      /\beven after\b/i,
      /\bdespite\b/i,
      /\binstead of\b/i
    ].freeze

    def call
      RETRY_COUNT.times do
        text = Prompt.new(:coaching_intro).execute
        error = validate(text)

        return text unless error
        puts error
      end

      nil
    end

    def self.test
      10.times.map.with_index(1) do |_, i|
        puts "Iteration: #{i}"
        new.call
      end.compact
    end

    private

    def validate(text)
      lines = nonempty_lines(text)

      return "First line must start with 'Imagine'" unless lines.first.start_with?("Imagine")
      return "Final line must end with a question mark" unless lines.last.end_with?("?")
      return "Metaphor or personification detected" if contains?(text, METAPHOR_PATTERNS)
      return "Interpretive language detected" if contains?(text, INTERPRETIVE_PHRASES)
      # return "Conjunction or transition detected in setup" if contains?(lines.first, TRANSITIONS_OR_CONJUNCTIONS)
      return "Must be 2–4 sentences" unless sentence_count_valid?(text)
      return "Sentence exceeds 20 words: #{long_sentence(text)}" if long_sentence(text)
      return "Final question does not reference first UI noun" unless question_references_first_noun?(lines)

      nil
    end

    def contains?(text, patterns)
      patterns.any? { |r| text =~ r }
    end

    def sentence_count_valid?(text)
      text.strip.scan(/[^.!?]+[.!?]/).size.between?(2, 4)
    end

    def long_sentence(text)
      text.strip.split(/(?<=[.!?])\s+/).find do |s|
        s.split.size > 20 && !s.strip.end_with?("?")
      end
    end

    def question_references_first_noun?(lines)
      first = lines.first
      last = lines.last
      noun = UI_NOUNS.find { |n| first =~ /\b#{Regexp.escape(n)}\b/i }
      noun && last =~ /\b#{Regexp.escape(noun)}\b/i
    end

    def nonempty_lines(text)
      text.strip.lines.map(&:strip).reject(&:empty?)
    end
  end
end