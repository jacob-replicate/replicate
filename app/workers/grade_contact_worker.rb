class GradeContactWorker
  include Sidekiq::Worker

  def perform(contact_id)
    contact = Contact.find_by(id: contact_id)
    return unless contact
    return if contact.score.present? && contact.score > 0 # already graded

    metadata = contact.metadata.deep_symbolize_keys

    result = Prompts::LeadScoring.new(context: { lead_metadata: metadata }).call rescue {}

    score = result["score"]&.to_i
    reason = result["reason"] || result["score_reason"]

    contact.update(
      score: score || 0,
      score_reason: reason.presence,
      metadata: contact.metadata.merge("scoring_output" => result)
    )
  end
end