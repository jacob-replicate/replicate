EXAMPLE_EMAILS = [
  {
    to: "Alex Shaw",
    subject: "N+1 query caused DB spike",
    content: "One loop explodes into hundreds of expensive queries. Let's talk about ways to catch these during PR review.",
    prompt: "shipped an N+1 query, and took down production for 6 minutes"
  },
  {
    to: "Casey Patel",
    subject: "SSO failed quietly, again",
    content: "Feature flags catch failures before users do. Skipping them turns a routine launch into a rescue mission.",
    prompt: "deploy broke SSO authentication in prod (forgot to feature flag new project)"
  },
  {
    to: "Taylor Morales",
    subject: "The rollback didn't work",
    content: "If our disaster recovery plan isn't tested, it isn't real. Break-glass deploys need their own playbook.",
    prompt: "hotfix made things worse, rollback also failed"
  }
]