MAX_RETRIES = 5

def reject_reason(text)
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

  nil
end

# Replace this stub with your actual LLM prompt call
def generate_intro
  Prompt.new(:coaching_intro).execute
end

approved = []

5.times do |i|
  puts "\n🧪 Iteration ##{i}"
  approved_intro = nil

  MAX_RETRIES.times do |attempt|
    intro = generate_intro
    reason = reject_reason(intro)

    if reason.nil?
      approved_intro = intro
      puts "✅ Approved (attempt #{attempt + 1}):\n#{intro}"
      approved << { approved_intro: intro }
      break
    else
      puts "⛔️ Rejected (attempt #{attempt + 1}): #{reason}"
      puts intro
    end
  end

  puts "❌ Failed after #{MAX_RETRIES} attempts" unless approved_intro
end; nil

puts approved