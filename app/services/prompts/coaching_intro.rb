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

    SOFT_LANGUAGE = [
      /\bnoticeable (enough )?to\b/i,
      /\bmake(s)? you wonder\b/i,
      /\bit's just\b/i,
      /\ba(n)? extra (beat|moment|second)\b/i,
      /\bhang(s)? (in the air|back)\b/i,
      /\bslight\b/i,
      /\bit (feels|seems|looks) (like|as if)?\b/i
    ].freeze

    WEAK_QUESTIONS = [
      /\bwhat's your first move\b/i,
      /\bhow would you debug\b/i,
      /\bcan you tell\b/i,
      /\bwhat happened\b/i
    ].freeze

    def initialize(issue_description:)
      @issue_description = issue_description
    end

    def call
      RETRY_COUNT.times do
        text = Prompt.new(:coaching_intro, context: { issue_description: @issue_description, question: @question }).execute
        error = validate(text)

        if error.present?
          puts "Failure: #{error}"
        else
          return "#{text} #{questions.sample}"
        end
      end

      nil
    end

    def self.test(issue_description)
      10.times.map.with_index(1) do |_, i|
        puts "Iteration: #{i}"
        new(issue_description: issue_description).call
      end.compact
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

    def validate(text)
      lines = nonempty_lines(text)

      return "First line must start with 'Imagine'" unless lines.first.start_with?("Imagine")
      return "Metaphor or personification detected" if contains?(text, METAPHOR_PATTERNS)
      return "Interpretive language detected" if contains?(text, INTERPRETIVE_PHRASES)
      return "Soft or narrative phrasing detected" if contains?(text, SOFT_LANGUAGE)
      return "Weak or off-tone question phrasing" if contains?(lines.last, WEAK_QUESTIONS)
      #return "Must be 2–4 sentences" unless sentence_count_valid?(text)
      return "Sentence exceeds 20 words: #{long_sentence(text)}" if long_sentence(text)
      # return "Final question does not reference first UI noun" unless question_references_first_noun?(lines)
      return "Redundant sentences detected" if redundant_sentences?(text)

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