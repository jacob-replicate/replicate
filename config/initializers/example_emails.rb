EXAMPLE_EMAILS = [
  {
    to: "Alex Shaw",
    subject: "N+1 query caused DB spike",
    content: "One small loop triggered 100 inefficient database calls, temporarily killing the site during peak traffic.",
    prompt: "A junior shipped an N+1 query that took down production for 6 minutes. We didn't have automation to catch it during PR review. How can <span class='font-medium'>replicate.info</span> help next time?"
  },
  {
    to: "Casey Patel",
    subject: "SSO failed silently, again",
    content: "The team launched a new authentication flow without feature gating it, causing SSO to fail in production.",
    prompt: "We launched a new authentication flow without feature gating it, causing SSO to fail in production. How can <span class='font-medium'>replicate.info</span> help next time?"
  },
  {
    to: "Taylor Morales",
    subject: "The rollback didn't work",
    content: "A late-night hotfix broke an invoicing job, and the rollback left customer data in a corrupted state.",
    prompt: "A late-night hotfix broke an invoicing job, and the rollback left customer data in a corrupted state. How can <span class='font-medium'>replicate.info</span> help next time?"
  }
]