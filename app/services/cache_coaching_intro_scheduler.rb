class CacheCoachingIntroScheduler
  def self.call
    prompt_combinations = []

    prompt_combinations += JUNIOR_INCIDENTS.map { |incident| build_prompt_inputs(:junior, incident) }

    [:mid, :senior, :staff].each do |level|
      prompt_combinations += WEB_INCIDENTS.map { |incident| build_prompt_inputs(level, incident) }
    end

    prompt_combinations.each_with_index do |prompt_input, i|
      Rails.logger.info "Scheduling caching of coaching intro LLM response in #{i} minutes for input hash #{prompt_input[:input_hash]}"
      # CacheLlmResponseWorker.perform_in(i.minutes, prompt_input)
    end

  end

  def self.build_prompt_inputs(difficulty, incident)
    Prompts::Base.build_inputs(
      conversation_type: :coaching,
      difficulty: difficulty,
      incident: incident.squish
    )
  end
end