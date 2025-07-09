EXAMPLE_EMAILS = [
  {
    to: "Alex Shaw",
    subject: "N+1 query caused DB spike",
    content: "One small loop caused 100+ inefficient database calls, and caused latency spikes during peak traffic.",
    prompt: "shipped an N+1 query, and took down production for 6 minutes"
  },
  {
    to: "Casey Patel",
    subject: "SSO failed quietly, again",
    content: "The team launched a new authentication flow without feature gating it, causing SSO to fail in production.",
    prompt: "deploy broke SSO authentication in prod (forgot to feature flag new project)"
  },
  {
    to: "Taylor Morales",
    subject: "The rollback didn't work",
    content: "A rushed hotfix made things worse, and the rollback didn't behave as the team expected.",
    prompt: "hotfix made things worse, rollback also failed"
  }
]