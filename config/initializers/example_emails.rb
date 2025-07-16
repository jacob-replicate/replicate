EXAMPLE_EMAILS = [
  {
    to: "Alex Shaw",
    subject: "ENV rotation crashed site",
    content: "Staging credentials were automatically rotated into production, triggering failures across downstream services.",
    prompt: "Staging secrets took down production website. Staging secrets were automatically rotated into production at midnight, breaking pipelines and triggering failures across dependent services."
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
    content: "A late-night deploy broke an invoicing job, and the rollback left customer data in a corrupted state.",
    prompt: "late-night deploy broke an invoicing job, and the rollback left customer data in a corrupted state"
  }
]