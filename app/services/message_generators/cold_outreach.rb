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
            "This stuff tends to hide until a SEV gives everyone permission to care.",
            "Not urgent. Just the kind of thing that earns attention later, one way or another.",
            "Quiet patterns like this usually don't make it onto the sprint board (until they break something)."
          ]
        },
        {
          email: "jacob@try-replicate.info",
          from_name: "Jacob from replicate.info", # TODO: Change this name
          signature: "Appreciate ya,<br/>Jacob",
          ctas: [
            "No follow-ups. Just thought it might resonate.",
            "Most teams only notice patterns like this after something breaks.",
            "It's easier to coach this stuff before someone's firefighting at 2:00am.",
            "Flagging in case it saves your team a nasty context switch later.",
            "Any chance someone's coding up a version of these incidents, and doesn't know it yet?",
            "I find that this stuff is easy to ignore, but hard to explain after the fact."
          ]
        },
        {
          email: "jcomer@try-replicate.info",
          from_name: "Jacob from Replicate",
          signature: "- JC",
          ctas: [
            "No pressure to respond, just putting it out there.",
            "Most teams don't coach around this stuff until it shows up in a postmortem.",
            "Just trying to catch this stuff upstream before it turns into something bigger.",
            "It usually takes a SEV before this stuff gets taken seriously. Doesn't have to.",
          ]
        },
        {
          email: "j.comer@try-replicate.info",
          from_name: "Jacob C",
          signature: "All the best,<br/>Jacob",
          ctas: [
            "Not expecting a reply. Just thought it might be relevant.",
            "Might be worth bookmarking for later?",
            "This stuff tends to stay invisible until it becomes urgent.",
            "Someone's probably already built around this and doesn't realize it yet.",
            "Might not matter now. Might show up in a postmortem later. Just thought I'd share."
          ]
        }
      ]
    end
  end
end