EXAMPLE_EMAILS = [
  {
    to: "Alex Shaw",
    subject: "Staging secrets took down prod",
    content: "Credentials rotated automatically at midnight, triggering failures across downstream services.",
    prompt: "Staging secrets took down prod. The secrets rotated automatically at midnight, breaking pipelines and triggering failures across dependent services."
  },
  {
    to: "Casey Patel",
    subject: "SSO failed silently, again",
    content: "The new auth flow went live without a feature flag. SSO failed for 17 minutes while the team scrambled for a fix.",
    prompt: "The new auth flow went live without a feature flag. SSO failed for 17 minutes while the team scrambled for a fix."
  },
  {
    to: "Taylor Morales",
    subject: "The rollback didn't work",
    content: "A late-night hotfix broke an invoicing job, and the rollback left customer data in a corrupted state.",
    prompt: "late-night hotfix broke an invoicing job, and the rollback left customer data in a corrupted state"
  }
]