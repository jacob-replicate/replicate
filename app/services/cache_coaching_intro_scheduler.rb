class CacheCoachingIntroScheduler
  def self.call
    prompt_combinations = []

    prompt_combinations += JUNIOR_INCIDENTS.map { |incident| build_prompt_inputs("junior", incident) }

    ["mid", "senior", "staff"].each do |level|
      prompt_combinations += WEB_INCIDENTS.map { |incident| build_prompt_inputs(level, incident) }
    end

    prompt_combinations.each_with_index do |prompt_input, i|
      CacheLlmResponseWorker.perform_in((i * 30).seconds, prompt_input)
    end

  end

  def self.build_prompt_inputs(difficulty, incident)
    Prompts::Base.build_inputs(
      conversation_type: "coaching",
      difficulty: difficulty,
      incident: incident.squish
    ).merge({ "max" => 3 })
  end
end