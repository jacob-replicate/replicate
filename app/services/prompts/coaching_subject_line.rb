module Prompts
  class CoachingSubjectLine < Prompts::Base
    def call
      formats = [
        "Why did {{key_element}} collapse under load?",
        "What mechanism bypassed an enforced boundary?",
        "Why did valid state yield invalid output?",
        "What invariant failed silently at scale?",
        "Which {{actors}} violated its safety contract?",
        "Why did safeguards amplify exposure instead?",
      ]

      @context[:format] = formats.sample

      fetch_valid_response.gsub("\"", "")
    end
  end
end