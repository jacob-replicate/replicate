class ColdEmailVariants
  def self.build(inbox:, contact:)
    greeting = "Hi #{contact.first_name},"
    footer = "Replicate Software, LLC - 131 Continental Dr, Suite 305, Newark, DE - <a href='https://replicate.info/contacts/#{contact.id}/unsubscribe'>Unsubscribe</a>"

    body_html = <<~HTML
      <p>#{greeting}</p>
      <p>#{intros.sample} #{tech_explanation.sample}</p>
      <p>#{ctas.sample}</p>
      <p>#{inbox["signature"]}</p>
      <p style="font-size: 80%; opacity: 0.6">#{footer}</p>
    HTML

    {
      "subject" => subjects.sample,
      "body_html" => body_html
    }
  end

  def self.count
    subjects.count * intros.count * tech_explanation.count * ctas.count
  end

  def self.subjects
    [
      "Learn from SEV-1s in practice, not production",
      "Data corruption that customers notice before you do",
      "Catch infra failures before PagerDuty does",
      "The retry storm that brought everything down",
      "1-line fix. 3-day incident.",
      "Replica lag that looks harmless... until it's not",
      "The rollback that quietly broke write consistency",
      "No logins. No dashboards. Just less downtime",
      "Drills that expose brittle assumptions in your stack",
      "Race conditions that only show up at scale",
      "5-minute production outage drills",
      "SEV-1 prevention without a new tool",
      "Latency spike? Or something worse hiding under the hood?",
      "The crash you swore CI would've caught",
      "One less postmortem to explain",
      "Fewer 2:00am pages this quarter",
    ]
  end

  def self.intros
    url = "<a href='https://replicate.info'>replicate.info</a>"
    [
      "I lead IAM projects for Terraform. I also built #{url} to help teams surface infra/sec blind spots before they hit prod.",
      "I'm a Staff Engineer at HashiCorp, and recently launched #{url} to help developers think clearly during production fires.",
      "I lead infra/sec work at IBM, and shipped #{url} to pressure-test engineers before production does.",
      "I've worked in production long enough to know where engineers get stuck, and built #{url} to cover those gaps.",
      "I'm an infra engineer who has seen too many SEVs that could've been caught in review. #{url} helps prevent them.",
    ]
  end

  def self.tech_explanation
    [
      "It's just a weekly email. GPT drops you into a SEV-1, asks for your next move, and applies pressure until you break.",
      "GPT emails your team a SEV every Monday, and grades their work. It's looking for the blind spots that crash prod.",
      "Each week, engineers get an email with a simulated production issue. They reply like it's real. GPT coaches from there.",
    ]
  end

  def self.ctas
    [
      "No ask. Just thought it might resonate.",
      "It's a little harsh. Uncompromising. Surgical, even. But so is production.",
      "SEV thinking, without the actual SEV.",
      "Sparring with GPT is more efficient than reading SRE books. Failure is the product."
    ]
  end
end