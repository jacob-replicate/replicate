chunks = [
  # Overview
  "replicate.info helps engineering leaders uncover team blind spots before they lead to outages or missed deadlines.",
  "Engineers receive lightweight, AI-powered coaching insights via email. It does not support other integrations (e.g., Slack, Teams, Zoom, etc).",
  "coaching insights begin Mondays and continue organically throughout the week.",
  "Conversations dig into core engineering concepts like secrets management, not surface-level tools or trivia.",
  "Based on responses, engineers get personalized learning tips and links to high-quality resources.",
  "Managers receive weekly inbox-friendly reports on morale, delivery risks, and growth progress.",
  "There's no dashboard, login, or setup overhead — everything runs through email.",

  # Manager reports
  "On Fridays, managers receive a single email with team-level insights.",
  "These include growth summaries per engineer, notable skill gaps, morale trends, and delivery risks.",
  "Reports may suggest cases for more headcount or tech debt cleanup.",
  "No login required — the assistant compiles and delivers everything.",
  "The assistant never surprises managers. Recommendations always align with team goals.",

  # Sales
  "It costs $30/mo (USD) per user.",
  "You can choose to pay a flat annual fee, without needing to manually track users. Email support@replicate.info for an offer."
]

chunks.each_with_index do |text, i|
  embedding = Embedder.embed(text)

  PromptChunk.create!(
    content: text.strip,
    embedding: "[#{embedding.join(',')}]"
  )
end