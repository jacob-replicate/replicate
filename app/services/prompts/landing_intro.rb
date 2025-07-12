module Prompts
  class CoachingIntro < Prompts::BasePrompt
    def initialize(conversation: nil, issue_description: nil)
      @issue_description = issue_description
    end

    def call
      Prompt.new(:landing_page_incident, context: conversation.context).execute

      Prompt.new(conversation.next_prompt_code, context: conversation.context, history: conversation.message_history).stream do |token|
        flusher << token
      end
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
      return "Sentence exceeds 20 words: #{long_sentence(text)}" if long_sentence(text)
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