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
          ctas: [
            "No ask. Just thought it might be worth sharing.",
            "If it's useful, great — if not, no problem.",
            "Would your team benefit from catching things like this earlier?",
            "I'd love your feedback if it resonated. No pressure though.",
            "I'd be curious how this reads from your side.",
            "Happy to hear where this does or doesn't line up with your reality."
          ]
        },
        {
          email: "jacob@try-replicate.info",
          signature: "Appreciate it,<br/>Jacob",
          from_name: "Jacob from replicate.info",
          ctas: [
            "No follow-ups. Just thought it might resonate.",
            "I'd love to hear your feedback if you have a few minutes.",
            "Curious how this would land with your team."
          ]
        },
        {
          email: "jcomer@try-replicate.info",
          signature: "- JC",
          from_name: "Jacob from Replicate",
          ctas: [
            "Might be worth surfacing before it hits prod.",
            "If it sparks anything, I'd love to hear where your thoughts.",
            "Not urgent, but felt worth putting on your radar. Let me know what you think.",
            "I'd love to hear what you think.",
            "If someone flagged this for you internally, would it stick?",
            "I'm curious how your team might benefit from something like this."
          ]
        },
        {
          email: "j.comer@try-replicate.info",
          signature: "All the best,<br/>Jacob",
          from_name: "Jacob C",
          ctas: [
            "I'm not expecting a reply. I just thought it might be relevant.",
            "This stuff tends to go untracked until it shows up at the wrong moment.",
            "I wanted to reach out in case it saves someone context-switching later.",
            "Just trying to make it easier to catch this stuff upstream — does that land?",
            "Seen this kind of thing hide in plain sight before — figured I'd surface it.",
          ]
        }
      ]
    end
  end
end