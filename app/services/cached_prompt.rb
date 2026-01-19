class CachedPrompt
  # Wraps a prompt class with caching logic.
  # Cache key is based on generation_intent.
  #
  # Usage:
  #   CachedPrompt.call(Prompts::IncidentIntro, generation_intent: "...", context: {})
  #   CachedPrompt.call(Prompts::IncidentIntro, generation_intent: "...", force: true)  # refresh cache
  #
  def self.call(prompt_class, generation_intent:, context: {}, force: false)
    return [] if Rails.env.test?

    cache_key = build_cache_key(generation_intent)
    template_name = prompt_class.name.demodulize.underscore

    unless force
      cached = CachedLlmResponse
        .where(template_name: template_name, input_hash: cache_key)
        .order(:updated_at)
        .last

      return cached.response if cached.present?
    end

    # Cache miss (or force refresh) - call the prompt
    response = prompt_class.new(context: context).call

    CachedLlmResponse.create!(
      template_name: template_name,
      input_hash: cache_key,
      response: response
    )

    response
  end

  def self.build_cache_key(generation_intent)
    Digest::MD5.hexdigest(generation_intent.to_s.downcase.squish)
  end
end