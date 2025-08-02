module MessageGenerators
  class ColdOutreach < MessageGenerators::Base
    def deliver_intro
      inbox = inboxes.find_by { |inbox| @conversation.context["cold_email_inbox"] == inbox[:email] } || inboxes.sample

      deliver_elements([
        "Hi #{@conversation.recipient.first_name}",
        inbox[:intro].sample,
        inbox[:hook].sample,
        inbox[:ctas].sample,
        inbox[:signature]
      ])
    end

    private

    def inboxes
      [
        jacob_inbox,
#        jacob_comer_inbox,
#        jcomer_inbox,
#        j_comer_inbox
      ]
    end

    def jacob_inbox
      {
        email: "jacob@try-replicate.info",
        from_name: "Jacob C",
        subjects: [
          "Preventing SEV-1s with weekly emails?",
          "GPT loops that surface infra/security blind spots",
          "A quieter way to sharpen production instincts",
          "Weekly drills to prevent your next postmortem",
          "Coaching SEV response (without the SEV)",
        ],
        intro: [
          "I lead IAM for Terraform. On the side, I shipped #{url} to help teams uncover their infra/security blind spots.",
          "I've been in lots of SEVs where judgment broke under pressure, so I built #{url} to help engineers sharpen their production instincts.",
          "I'm a Staff Engineer at HashiCorp, and recently launched #{url} to help developers think clearly during production fires.",
          "I spent years in incident threads where we all missed the same failure pattern. I launched #{url} recently to help ICs catch that stuff earlier — <i>without</i> needing a SEV to learn it.",
          "I work at HashiCorp, and recently built a side project called #{url}. It helps surface infra/security risks before shipping to prod.",
        ],
        hook: [
          "Every Monday, GPT emails you a high-stakes production fire, and makes you reason through it. It keeps pushing until you reach failure, and <strong>then</strong> the coaching starts.",
          "It's a weekly pressure test delivered over email. GPT drops you into a SEV1, asks where you'd look first, and pushes back on your thinking.",
          "It's just a weekly email. GPT throws you into an incident, and forces you to break it down under pressure. Then it points out what you missed.",
        ],
        ctas: [
          "No follow-ups. Just thought it might resonate.",
          "I'd love to hear your feedback, but no pressure to respond.",
          "It should be easier to coach this stuff before the 2:00am firefighting starts.",
          "Just wanted to flag in case it saves your team a rough PagerDuty alert later.",
          "This stuff tends to stay invisible until it becomes urgent.",
        ],
        signature: "Cheers,<br/>Jacob"
      }
    end

    def jacob_comer_inbox
      {
        email: "jacob.comer@try-replicate.info",
        from_name: "Jacob Comer",
        signature: "-- Jacob Comer",
        intro: [
          "I lead IAM at Terraform — lots of policy edge cases and incident forensics.",
          "Been working on Terraform's identity systems for the past few years.",
          "I'm a Staff Engineer in Virginia, mostly deep in Terraform IAM and auth flow design.",
          "Terraform platform team — my lane is IAM and damage control.",
          "I've spent a few years in the IAM guts of Terraform. It's always fine until it's not."
        ],
        hook: [
          "Replicate is a weekly inbox loop for surfacing infra/security blind spots before they turn urgent.",
          "It's not a SaaS tool — just email-only coaching that helps engineers catch risks earlier.",
          "Each email is a short drill built from real failure patterns. No tracking, no fluff.",
          "It's designed to simulate postmortem-grade pressure, without needing an actual SEV.",
          "Just one scenario per week. No UI. But it tends to travel fast inside teams."
        ],
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
        intro: [
          "I'm on the Terraform IAM team — my job is preventing future retros.",
          "I work on identity controls and system safety at Terraform.",
          "I've led IAM for Terraform for a few years now — mostly the stuff no one notices until it fails.",
          "Terraform engineering, IAM lead. I spend a lot of time thinking about preventable SEVs.",
          "Infra at Terraform. IAM is the part that breaks when people think it won't."
        ],
        hook: [
          "This isn't a product demo — just a coaching loop that lands in your inbox.",
          "No UI. No integration. Just pressure-tested judgment reps in email form.",
          "Engineers get one short thread per week that simulates an incident without needing one.",
          "It's quiet, sharp, and designed to travel internally without dashboards or metrics.",
          "Replicate delivers weekly incident-grade prompts that train thinking, not reporting."
        ],
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
        intro: [
          "I lead IAM for Terraform — mostly production access, policy edge cases, and postmortems.",
          "Staff+ at Terraform, focused on reliability inside identity workflows.",
          "I've worked on Terraform's IAM internals for a while now. Most of it doesn't break loudly — until it does.",
          "Virginia-based Staff Engineer, Terraform IAM team. This stuff rarely breaks cleanly.",
          "My lane at Terraform is IAM and platform resilience. It gets stressful fast when it slips."
        ],
        hook: [
          "Replicate is inbox-native coaching designed to surface weak spots before someone escalates.",
          "It's failure pattern recognition delivered weekly, without metrics or nudges.",
          "The product is just one short email a week — designed to hit like a peer asking, 'what would you miss here?'",
          "No interface. No dashboard. Just a quiet loop that helps engineers prevent postmortems.",
          "Each email is written to feel like a Staff peer flagging a near-miss — and it usually lands that way."
        ],
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