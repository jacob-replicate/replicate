EXAMPLE_EMAILS = [
  {
    to: "Alex Shaw",
    subject: "N+1 query caused DB spike",
    content: "One small loop triggered 100 inefficient database calls, temporarily killing the site during peak traffic.",
    prompt: "shipped an N+1 query that took down production for 6 minutes - didn't have automation in place to catch during PR review"
  },
  {
    to: "Casey Patel",
    subject: "SSO failed silently, again",
    content: "The team launched a new authentication flow without feature gating it, causing SSO to fail in production.",
    prompt: "deploy broke SSO authentication in prod (forgot to feature flag new project)"
  },
  {
    to: "Taylor Morales",
    subject: "The rollback didn't work",
    content: "A late-night hotfix broke a background job, and the rollback failed to restore deleted customer records.",
    prompt: "hotfix broke data pipeline, rollback didn't recover lost customer records"
  }
]