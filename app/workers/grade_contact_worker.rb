class GradeContactWorker
  include Sidekiq::Worker

  sidekiq_options retry: false, lock: :until_executed

  def perform(contact_id, force = false)
    contact = Contact.find_by(id: contact_id)
    return unless contact
    return if (contact.score.present? && contact.score > 0) && !force

    metadata = contact.metadata.deep_symbolize_keys

    result = Prompts::LeadScoring.new(context: { lead_metadata: metadata }).call

    score = result["score"]
    reason = result["reason"]

    contact.update!(score: score, score_reason: reason.presence)
  end
end