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
      "It's a weekly pressure test delivered over email. GPT drops you into a SEV-1, asks where you'd look first, and pushes back on your thinking.",
      "It's just a weekly email. GPT throws you into an incident, and forces you to break it down under pressure. Then it points out what you missed.",
    ]
  end

  def self.ctas
    [
      "No ask. Just thought it might resonate.",
      "Figured I'd send this once and leave it up to you.",
      "It's wild how good LLMs are now. They still kinda suck at writing code, but they're great at this stuff.",
      "It took me way too long to learn this stuff — hoping I can help save someone else the time.",
      "It's a little harsh. Uncompromising. Surgical, even. But I think that helps you learn faster.",
      "SEV thinking, without the actual SEV.",
      "I built this for myself, and figured the community might find it useful too.",
    ]
  end

  def self.inboxes
    [
      {
        email: "jc@try-replicate.info",
        from_name: "J.C. (Replicate)",
        signature: "Best,<br/>J.C."
      },
      {
        email: "jacob@try-replicate.info",
        from_name: "Jacob C.",
        signature: "-- Jacob"
      },
      {
        email: "jake@try-replicate.info",
        from_name: "Jake from Replicate",
        signature: "All the best,<br/>Jake"
      },
      {
        email: "comer@try-replicate.info",
        from_name: "J. Comer",
        signature: "Appreciate ya!"
      },
    ]
  end
end