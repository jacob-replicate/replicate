class ColdEmailVariants
  def self.build(inbox:, contact:)
    greeting = "Hi #{contact.first_name},"
    footer = "Replicate Software, LLC - 131 Continental Dr, Suite 305, Newark, DE - <a href='https://replicate.info/contacts/#{contact.id}/unsubscribe'>Unsubscribe</a>"

    body_html = <<~HTML
      #{greeting}
      <p>#{intros.sample}</p>
      <p>#{tech_explanation.sample} #{ctas.sample}</p>
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
      "Drills that expose brittle assumptions in your stack",
      "Race conditions that only show up at scale",
      "5-minute production outage drills",
      "SEV-1 prevention (without a new tool)",
      "Latency spike? Or something worse hiding under the hood?",
    ]
  end

  def self.intros
    url = "<a href='https://replicate.info'>replicate.info</a>"
    [
      "I built #{url} to help engineers catch SEV-1's before production does.",
      "I've spent most of my career doing infra/sec, and built #{url} to help engineers sharpen their production instincts.",
      "I've seen how infra blind spots turn into outages, and built #{url} to help teams fix those gaps in a safe environment.",
      "After years of putting out infra/sec fires, I built #{url} to help teams feel more confident in production.",
      "I've been hit by too many SEVs that could've been caught in review, and built #{url} to prevent them.",
      "I've scaled infra long enough to know where most engineers get stuck, and built #{url} to bridge those gaps.",
    ]
  end

  def self.tech_explanation
    [
      "It's just a weekly email. GPT drops you into a SEV, asks for your next move, and applies pressure until your mental model starts to crack.",
      "GPT emails your team a SEV every Monday, and makes them think through it in private threads. It keeps poking until it finds a blind spot that could crash prod.",
    ]
  end

  def self.ctas
    [
      "Happy to share more if you're curious.",
      "It's 100% async if you decide to try it out.",
      "It's a little harsh/uncompromising, but so is production.",
      "SEV thinking, without the actual SEV.",
      "Every team has blind spots. This helps you find them before production does.",
      "Nothing to install/configure if you're interested.",
    ]
  end
end