class CacheExperienceWorker
  include Sidekiq::Worker

  def perform(experience_id)
    experience = Experience.find_by(id: experience_id)
    return unless experience

    experience.elements.root_level.each do |element|
      cache_element_response(element)
    end
  end

  private

  def cache_element_response(element)
    case element.code
    when "incident_cta"
      cache_incident_responses(element)
    end
  end

  def cache_incident_responses(element)
    return if element.generation_intent.blank?

    CachedPrompt.call(Prompts::IncidentIntro, generation_intent: element.generation_intent, force: true)
    CachedPrompt.call(Prompts::IncidentTitle, generation_intent: element.generation_intent, force: true)
    CachedPrompt.call(Prompts::MultipleChoiceOptions, generation_intent: element.generation_intent, force: true)
  end
end