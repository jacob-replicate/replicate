class ColdEmailGenerator
  WORKDAY_HOURS = (9..17).to_a.freeze # 9 AM – 5 PM
  MAX_PER_DAY = 30
  MAX_PER_HOUR = 5

  def self.call(count:)
    leads = Contact.where(contacted: false)
                   .where.not(email: nil)
                   .where("score >= 80")
                   .limit(count)

    inbox_pool = inboxes.map { |inbox| inbox.merge(weight: rand(0.8..1.2)) }
                        .flat_map { |inbox| Array.new((inbox[:weight] * 100).to_i, inbox) }

    # Build realistic send schedule
    schedule = build_daily_schedule(leads.size)

    leads.each_with_index do |lead, idx|
      unless lead.passed_bounce_check?
        lead.update(email: nil, score: -1)
        next
      end

      inbox = inbox_pool.sample

      variant_index = VariantCounter.increment!("cold_outreach_index:#{inbox[:email]}") - 1

      subject_index =  variant_index / (intros.size * hooks.size * ctas.size)
      intro_index   = (variant_index / (hooks.size * ctas.size)) % intros.size
      hook_index    = (variant_index / ctas.size) % hooks.size
      cta_index     =  variant_index % ctas.size

      subject = subjects[subject_index % subjects.size]
      intro   = intros[intro_index % intros.size]
      hook    = hooks[hook_index % hooks.size]
      cta     = ctas[cta_index % ctas.size]

      body = <<~HTML
        #{intro}

        #{hook}

        #{cta}

        #{inbox[:signature]}<br/><br/>
        <span style="font-size: 14px">Replicate Software, LLC – 131 Continental Dr, Suite 305, Newark, DE (19713) – Unsubscribe</span>
      HTML

      send_time = schedule[idx]
      SendColdEmailWorker.perform_in(send_time, lead.email, subject, body)
    end
  end

  def self.build_daily_schedule(total_emails)
    emails_per_day = rand((MAX_PER_DAY - 5)..(MAX_PER_DAY + 2))
    emails_per_day = [emails_per_day, total_emails].min

    slots = WORKDAY_HOURS.flat_map do |hour|
      count_this_hour = rand(0..MAX_PER_HOUR)
      Array.new(count_this_hour) { Time.now.change(hour: hour, min: rand(0..59)) }
    end

    slots.sort.first(emails_per_day).map do |time|
      delay_seconds = time - Time.now
      delay_seconds.positive? ? delay_seconds : rand(60..600) # if already past, push into near future
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
      "Every Monday, GPT emails you a high-stakes production fire, makes you reason through it, and keeps pushing until you reach failure. <strong>Then</strong> the coaching starts.",
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
      "It's a little harsh. Uncompromising. Surgical, even. But so is production.",
      "SEV thinking, without the actual SEV.",
      "I built this for myself, and figured the community might find it useful too.",
      "Sparring with GPT is more efficient than reading 300-page books. Failure helps you grow faster.",
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