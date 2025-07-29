module MessageGenerators
  class ColdOutreach < MessageGenerators::Base
    def deliver_intro
      inbox = fetch_inbox

      [
        "Hi #{@conversation.recipient.first_name}",
        inbox[:ctas].sample,
        inbox[:signature]
      ]
    end

    private

    def fetch_inbox
      [
        {
          email: "jacob.comer@try-replicate.info",
          signature: "- Jacob",
          from_name: "Jacob Comer",
          ai_context: "Sends like a calm, precise Staff+ engineer. Expects high-context readers, avoids urgency, and treats feedback as optional signal, not a goal.",
          ctas: [
            "No ask. Just thought it might be worth sharing.",
            "If it's useful, great — if not, no problem.",
            "Would your team benefit from catching things like this earlier?",
            "I'd love your feedback if it resonated. No pressure though.",
            "I'd be curious how this comes across from your side.",
            "Happy to hear where this does or doesn't line up with your reality."
          ]
        },
        {
          email: "jacob@try-replicate.info",
          signature: "Appreciate it,<br/>Jacob",
          from_name: "Jacob from replicate.info",
          ai_context: "Soft-spoken and team-aware. Writes like someone who thinks about reliability at the org layer and nudges without pushing. Always assumes reader is busy and capable.",
          ctas: [
            "No follow-ups. Just thought it might resonate.",
            "I'd love to hear your feedback if you have a few minutes.",
            "Curious how this would land with your team.",
            "If this sparked anything, I'd love to hear what came up.",
            "No pressure to respond — just putting it out there in case it's helpful.",
            "Let me know if this reads clean or feels off — both are useful."
          ]
        },
        {
          email: "jcomer@try-replicate.info",
          signature: "- JC",
          from_name: "Jacob from Replicate",
          ai_context: "Direct and incident-oriented. Surfaces risk early, frames like a teammate who's seen systems fail, and doesn't waste time justifying signal.",
          ctas: [
            "Might be worth surfacing before it hits prod.",
            "If it sparked anything, I'd love to hear where your head went.",
            "Not urgent — just seemed worth naming while it's still boring.",
            "Let me know what stands out or feels off — either's useful.",
            "If someone flagged this internally, would it get traction?",
            "Would this kind of thing get caught in your review loop?"
          ]
        },
        {
          email: "j.comer@try-replicate.info",
          signature: "All the best,<br/>Jacob",
          from_name: "Jacob C",
          ai_context: "Writes like someone who's already written the postmortem. Reflective, steady, and focused on helping others avoid known blind spots.",
          ctas: [
            "Not expecting a reply. Just thought it might be relevant.",
            "This stuff tends to stay invisible until it becomes urgent.",
            "Flagging in case it saves someone a nasty context switch later.",
            "Trying to catch this upstream before it turns into something bigger.",
            "If this spares someone a 3am scramble, it's done its job.",
            "Seen this kind of thing drift past too many teams — figured I'd surface it.",
          ]
        }
      ]
    end
  end
end