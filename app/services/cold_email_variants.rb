class ColdEmailVariants
  def self.build(inbox:, contact:)
    greeting = "Hi #{contact.first_name},"
    footer = "Replicate Software, LLC – 131 Continental Dr, Suite 305, Newark, DE (19713) – <a href='https://replicate.info/contacts/#{contact.id}/unsubscribe'>Unsubscribe</a>"

    body_html = <<~HTML
      <p>#{greeting}</p>
      <p>#{intros.sample} #{hooks.sample}</p>
      <p>#{ctas.sample}</p>
      <p>#{inbox[:signature]}</p>
      <p style="font-size: 80%; opacity: 0.6">#{footer}</p>
    HTML

    { subject: subjects.sample, body_html: body_html }
  end

  def self.subjects
    [
      "Preventing SEV-1s with weekly emails?",
      "GPT loops that surface infra/security blind spots",
      "A quieter way to sharpen production instincts",
      "Weekly drills to prevent your next postmortem",
      "Coaching SEV response (without the SEV)"
    ]
  end

  def self.intros
    url = "<a href='https://replicate.info' style='font-weight: bold'>replicate.info</a>"
    [
      "I lead IAM for Terraform. On the side, I shipped #{url} to help teams uncover their infra/security blind spots.",
      "I've been in lots of SEVs where judgment broke under pressure, so I built #{url} to help engineers sharpen their production instincts.",
      "I'm a Staff Engineer at HashiCorp, and recently launched #{url} to help developers think clearly during production fires.",
      "I spent years in incident threads where we all missed the same failure pattern. I launched #{url} recently to help ICs catch that stuff earlier — <i>without</i> needing a SEV to learn it.",
      "I work at HashiCorp, and recently built a side project called #{url}. It helps surface infra/security risks before shipping to prod."
    ]
  end

  def self.hooks
    [
      "GPT emails you a high-stakes production fire every Monday, makes you reason through it, and keeps pushing until you fail. <strong>Then</strong> the coaching starts.",
      "It's a weekly pressure test delivered over email. GPT drops you into a SEV-1, asks where you'd look first, and pushes back on your thinking.",
      "It's just a weekly email. GPT throws you into an incident, and forces you to break it down under pressure. Then it points out what you missed."
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
      "Sparring with GPT is more efficient than reading 300-page books. Failure helps you grow faster."
    ]
  end
end