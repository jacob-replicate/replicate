class ColdEmailVariants
  def self.build(inbox:, contact:)
    greeting = "Hi #{contact.first_name},"
    footer = "Replicate Software, LLC - 131 Continental Dr, Suite 305, Newark, DE - <a href='https://replicate.info/contacts/#{contact.id}/unsubscribe'>Unsubscribe</a>"

    body_html = <<~HTML
      #{greeting}
      <p>#{intros.sample}</p>
      <p>#{tech_explanation.sample}</p>
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
      "SEV-1 prevention (without a new tool)",
      "Latency spike? Or something worse hiding under the hood?",
    ]
  end

  def self.intros
    url = "<a href='https://replicate.info'>replicate.info</a>"
    [
      "I design IAM systems for S&P 500 platform teams, and built #{url} to help engineers catch SEVs before production does.",
      "I've spent my career in infra/sec, and built #{url} to help engineering teams sharpen their production instincts.",
      "I've seen how infra blind spots transform into outages, and built #{url} to help engineers surface those gaps in a safe environment.",
      "After years of putting out infra/sec fires, I built #{url} to help teams spot blind spots earlier.",
      "I've scaled infra where downtime costs millions, and created #{url} to help teams feel more confident in production.",
      "I'm an infra engineer who has seen too many SEVs that could've been caught in review. #{url} helps prevent them.",
      "I've worked in production long enough to know where engineers get stuck, and built #{url} to bridge those gaps.",
    ]
  end

  def self.tech_explanation
    [
      "It's just a weekly email. GPT drops you into a SEV-1, asks for your next move, and applies pressure until your mental model starts to crack.",
      "GPT emails your team a SEV every Monday, and makes them work through it in private threads. It applies pressure, and tries to uncover blind spots that will eventually crash prod.",
      "Each week, engineers get an email with a simulated production fire. They reply like it's real, and GPT escalates when it sees them start to slip.",
    ]
  end

  def self.ctas
    [
      "Just thought it might resonate. Happy to share more details if you're curious.",
      "It's 100% async if you decide to try it out.",
      "It's a little harsh/uncompromising, but so is production.",
      "SEV thinking, without the actual SEV. I'd love to hear what you think.",
      "The goal is to expose blind spots before production does. Curious if it resonates.",
      "1on1 threads, with sharp questions that make you reconsider how infra fails.",
      "Every team has blind spots. This helps you surface them before production does.",
      "Nothing to install/configure, just infra puzzles that show up in your inbox every week.",
    ]
  end
end