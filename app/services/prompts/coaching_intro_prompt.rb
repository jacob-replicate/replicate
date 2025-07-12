class CoachingIntroPrompt
  def self.call
    iteration = 0

    while iteration < retry_count
      text = Prompt.new(:coaching_intro).execute
      error_message = error_message(text)

      if error_message.present?
        puts error_message
      else
        return text
      end

      iteration += 1
    end

    nil
  end

  private

  def retry_count
    10
  end

  def error_message(text)
    metaphor_phrases = [
      /\blike\b/i,
      /\bas if\b/i,
      /\bas though\b/i,
      /\bseems to\b/i,
      /\bfeels like\b/i,
      /\bcatching a glimpse\b/i,
      /\bfrozen in time\b/i,
      /\bwaiting for something that never comes\b/i,
      /\bsits there\b/i,
      /\bseems content\b/i,
      /\bno sign of\b/i,
      /bstays frozen\b/i,
      /bstays that way\b/i,
    ]
    return "Metaphor or personification detected" if metaphor_phrases.any? { |r| text =~ r }

    lines = text.strip.split("\n").reject(&:empty?)
    return "Missing question line" unless lines.last&.end_with?("?")

    sentences = text.strip.scan(/[^.!?]+[.!?]/).map(&:strip)
    return "Must be 2–4 sentences" unless sentences.size.between?(2, 4)

    first_noun = lines.first[/\b(?:spinner|button|dropdown|list|summary|form|field|tab|ticket|page|label|log|users?)\b/i]
    unless first_noun && lines.last.downcase.include?(first_noun.downcase)
      return "Final question does not reference first UI element"
    end

    long_line = lines.find { |s| s.split.size > 20 && !s.end_with?("?") }
    return "Sentence exceeds 20 words: #{long_line}" if long_line

    true
  end
end