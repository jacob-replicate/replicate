class NextIncidentSelector
  def self.call(organization)
    seen_prompts = Conversation.where(recipient: organization.members.subscribed).pluck(Arel.sql("context ->> 'incident'")).reject(&:blank?)
    available = EMAIL_INCIDENTS.reject { |incident| seen_prompts.include?(incident[:prompt]) }
    available.sample
  end
end