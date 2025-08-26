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

  def self.subjects
    [
      "SEV-1 prevention without a new tool",
      "5-minute production outage drills",
      "Your next outage is avoidable",
      "One less postmortem to explain",
      "Fewer 2:00am pages this quarter",
      "Catch SEV-1s in practice, not prod",
      "Data corruption that customers notice before you do",
      "Replica lag that looks harmless... until it's not"
    ]
  end

  def self.intros
    url = "<a href='https://replicate.info'>replicate.info</a>"
    [
      "I lead IAM projects for Terraform. I also built #{url} to help teams surface infra/sec blind spots before they hit prod.",
      "I'm a Staff Engineer at HashiCorp, and recently launched #{url} to help developers think clearly during production fires.",
      "I lead infra/sec work at IBM, and shipped #{url} to pressure-test engineers before production does."
    ]
  end

  def self.tech_explanation
    [
      "It's just a weekly email. GPT drops you into a SEV-1, asks for your next move, and applies pressure until you break.",
      "GPT emails your team a SEV every Monday, and grades their work. It's looking for the blind spots that crash prod.",
    ]
  end

  def self.ctas
    [
      "No ask. Just thought it might resonate.",
      "Just one send — you'll know if it's useful.",
      "It's a little harsh. Uncompromising. Surgical, even. But so is production.",
      "SEV thinking, without the actual SEV.",
      "Sparring with GPT is more efficient than reading SRE books. Failure is the product."
    ]
  end
end