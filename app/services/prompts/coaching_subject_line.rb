module Prompts
  class CoachingSubjectLine < Prompts::Base
    def call
      formats = [
        # Contrast questions — invite “why the mismatch?”
        "Contrast question — why one system stays stable while another fails.",

        # Inversion questions — system does the opposite of expected.
        "Inversion question — why protection or stability created exposure instead.",

        # Symptom chain questions — walk through three signals, end with a puzzle.
        "Symptom chain question — X rose, Y stalled, Z vanished, what broke first.",

        # Snapshot questions — precise observation, flipped into a question.
        "Snapshot question — state a fact, then ask how it happened.",

        # Entity/path questions — point to the component, but not accusatory.
        "Entity question — which scope, route, or process allowed the failure."
      ]

      @context[:format] = formats.sample

      fetch_valid_response.gsub("\"", "")
    end
  end
end