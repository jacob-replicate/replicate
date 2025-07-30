module MessageGenerators
  class ColdOutreach < MessageGenerators::Base
    def deliver_intro
      inbox = fetch_inbox

      # TODO: Make the middle sections dynamic (per inbox) eventually.
      deliver_elements([
        "Hi #{@conversation.recipient.first_name}",
        "I'm a Staff Engineer from VA (currently leading IAM for Terraform), and I built <a href='https://replicate.info'>replicate.info</a> to help engineers sharpen their production instincts.",
        "There's no UI. It's just a weekly email that surfaces infra/security blind spots, and helps engineers think through them with GPT.",
        inbox[:ctas].sample,
        inbox[:signature]
      ])
    end

    private

    def fetch_inbox
      [
        {
          email: "jacob.comer@try-replicate.info",
          from_name: "Jacob Comer",
          signature: "- Jacob",
          ctas: [
            "No ask. Just thought it might be worth sharing.",
            "Would your team benefit from catching things like this earlier?",
            "I'd love your feedback if it resonated. No pressure to reply.",
            "Curious how this would land with your team.",
          ]
        },
        {
          email: "jacob@try-replicate.info",
          from_name: "Jacob from replicate.info",
          signature: "Appreciate it,<br/>Jacob",
          ctas: [
            "No follow-ups. Just thought it might resonate.",
            "I'd love to hear your feedback if you have a few minutes.",
            "If this sparked anything, I'd love to hear what came up.",
            "No pressure to respond, just putting it out there.",
          ]
        },
        {
          email: "jcomer@try-replicate.info",
          from_name: "Jacob from Replicate",
          signature: "- JC",
          ctas: [
            "Would this get traction if someone flagged it internally?",
            "Might be worth bookmarking for later?",
          ]
        },
        {
          email: "j.comer@try-replicate.info",
          from_name: "Jacob C",
          signature: "All the best,<br/>Jacob",
          ctas: [
            "Not expecting a reply. Just thought it might be relevant.",
            "This stuff tends to stay invisible until it becomes urgent.",
            "Flagging in case it saves your team a nasty context switch later.",
            "Just trying to catch this stuff upstream before it turns into something bigger.",
          ]
        }
      ]
    end
  end
end