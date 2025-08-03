class ColdEmailGenerator
  def self.call(count:)
    leads = Contact.where(contacted: false).limit(count)

    inbox_pool = inboxes.map { |inbox| inbox.merge(weight: rand(0.8..1.2)) }
                        .flat_map { |inbox| Array.new((inbox[:weight] * 100).to_i, inbox) }

    leads.each do |lead|
      inbox = inbox_pool.sample

      variant_index = VariantCounter.increment!("cold_outreach_index:#{inbox[:email]}") - 1

      subject_index =  variant_index / (intros.size * hooks.size * ctas.size)
      intro_index   = (variant_index / (hooks.size * ctas.size)) % intros.size
      hook_index    = (variant_index / ctas.size) % hooks.size
      cta_index     =  variant_index % ctas.size

      lead.conversations.create!(
        context: {
          conversation_type: "cold_outreach",
          from_name: inbox[:from_name],
          email: inbox[:email],
          subject: subjects[subject_index % subjects.size],
          intro:   intros[intro_index % intros.size],
          hook:    hooks[hook_index % hooks.size],
          cta:     ctas[cta_index % ctas.size],
          footer: "Replicate Software, LLC  - 131 Continental Dr, Suite 305, Newark, DE (19713) - Unsubscribe", # TODO: Make unsubscribe link
          signature: inbox[:signature],
        }
      )
    end
  end

  def self.subjects
    [
      "Preventing SEV-1s with weekly emails?",
      "GPT loops that surface infra/security blind spots",
      "A quieter way to sharpen production instincts",
      "Weekly drills to prevent your next postmortem",
      "Coaching SEV response (without the SEV)",
    ]
  end

  def self.intros
    url = "https://replicate.info"
    [
      "I lead IAM for Terraform. On the side, I shipped #{url} to help teams uncover their infra/security blind spots.",
      "I've been in lots of SEVs where judgment broke under pressure, so I built #{url} to help engineers sharpen their production instincts.",
      "I'm a Staff Engineer at HashiCorp, and recently launched #{url} to help developers think clearly during production fires.",
      "I spent years in incident threads where we all missed the same failure pattern. I launched #{url} recently to help ICs catch that stuff earlier — <i>without</i> needing a SEV to learn it.",
      "I work at HashiCorp, and recently built a side project called #{url}. It helps surface infra/security risks before shipping to prod.",
    ]
  end

  def self.hooks
    [
      "Every Monday, GPT emails you a high-stakes production fire, and makes you reason through it. It keeps pushing until you reach failure, and <strong>then</strong> the coaching starts.",
      "It's a weekly pressure test delivered over email. GPT drops you into a SEV1, asks where you'd look first, and pushes back on your thinking.",
      "It's just a weekly email. GPT throws you into an incident, and forces you to break it down under pressure. Then it points out what you missed.",
    ]
  end

  def self.ctas
    [
      "No follow-ups. Just thought it might resonate.",
      "I'd love to hear your feedback, but no pressure to respond.",
      "It should be easier to coach this stuff before the 2:00am firefighting starts.",
      "Just wanted to flag in case it saves your team a rough PagerDuty alert later.",
      "This stuff tends to stay invisible until it becomes urgent.",
    ]
  end

  def self.inboxes
    [
      {
        email: "jacob@try-replicate.info",
        from_name: "Jacob C",
        signature: "Cheers,<br/>Jacob"
      },
      {
        email: "jacob.comer@try-replicate.info",
        from_name: "Jacob Comer",
        signature: "-- Jacob Comer"
      },
      {
        email: "jcomer@try-replicate.info",
        from_name: "Jacob @ Replicate",
        signature: "~ J"
      },
      {
        email: "j.comer@try-replicate.info",
        from_name: "Jake Comer",
        signature: "All the best,<br/>Jake"
      }
    ]
  end
end