class CacheLlmResponseWorker
  include Sidekiq::Worker

  def perform(prompt_input)
    Rails.logger.info "Caching LLM response for input hash #{prompt_input['input_hash']} - #{prompt_input.to_json} - #{prompt_input.class}"
    Prompts::CoachingIntro.new(context: prompt_input, cacheable: true, force_cache: true).call
    Prompts::CoachingTitle.new(context: prompt_input, cacheable: true, force_cache: true).call
    Prompts::MultipleChoiceOptions.new(context: prompt_input, cacheable: true, force_cache: true).call
  end
end