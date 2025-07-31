module MessageGenerators
  class ColdOutreach < MessageGenerators::Base
    def deliver_intro
      inbox = inboxes.find_by { |inbox| @conversation.context["cold_email_inbox"] == inbox[:email] } || inboxes.sample

      deliver_elements([
        "Hi #{@conversation.recipient.first_name}",
        "I'm a Staff Engineer from VA (currently leading IAM for Terraform), and I built <a href='https://replicate.info'>replicate.info</a> to help engineers sharpen their production instincts.",
        "There's no UI. It's just a weekly email that surfaces infra/security blind spots, and helps engineers think through them with GPT.",
        inbox[:ctas].sample,
        inbox[:signature]
      ])
    end

    private

    def inboxes
      [
        jacob_comer_inbox,
        jacob_inbox,
        jcomer_inbox,
        j_comer_inbox
      ]
    end

    def jacob_inbox
      {
        email: "jacob@try-replicate.info",
        from_name: "Jacob C",
        signature: "Cheers,<br/>Jacob",
        ctas: [
          "No follow-ups. Just thought it might resonate.",
          "Most teams only notice patterns like this after something breaks.",
          "It's easier to coach this stuff before someone's firefighting at 2:00am.",
          "Flagging in case it saves your team a nasty context switch later.",
          "I find that this stuff is easy to ignore, but hard to explain after the fact."
        ]
      }
    end

    def jacob_comer_inbox
      {
        email: "jacob.comer@try-replicate.info",
        from_name: "Jacob Comer",
        signature: "-- Jacob Comer",
        ctas: [
          "No ask. Just thought it might be worth sharing.",
          "This stuff tends to hide until a SEV gives everyone permission to care.",
          "Not urgent. Just the kind of thing that earns attention later, one way or another.",
          "Quiet patterns like this usually don't make it onto the sprint board (until they break something).",
          "By the time it's visible, someone's already downstream of the impact.",
          "Once everything's tangled, you're stuck explaining decisions nobody remembers making."
        ]
      }
    end

    def jcomer_inbox
      {
        email: "jcomer@try-replicate.info",
        from_name: "Jacob @ Replicate",
        signature: "~ J",
        ctas: [
          "Most teams don't coach around this stuff until it shows up in a postmortem.",
          "Harder to catch upstream. Easier to regret downstream.",
          "It usually takes a SEV before this stuff gets taken seriously. Doesn't have to.",
          "Could be noise. Could be what prevents next quarter's incident writeup."
        ]
      }
    end

    def j_comer_inbox
      {
        email: "j.comer@try-replicate.info",
        from_name: "Jake Comer",
        signature: "All the best,<br/>Jake",
        ctas: [
          "Not expecting a reply. Just thought it might be relevant.",
          "Sometimes these sit quiet for months. Then suddenly they matter.",
          "This stuff tends to stay invisible until it becomes urgent.",
          "Might not matter now. Might show up in a postmortem later. Just thought I'd share."
        ]
      }
    end
  end
end