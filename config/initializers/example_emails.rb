EXAMPLE_EMAILS = [
  {
    to: "Alex Shaw",
    subject: "ENV rotation crashed site",
    content: "Staging credentials were automatically rotated into production, triggering failures in downstream services.",
    prompt: "Staging secrets took down production website. Staging secrets were automatically rotated into production at midnight, breaking pipelines and triggering failures across downstream services."
  },
  {
    to: "Casey Patel",
    subject: "SSO failed silently, again",
    content: "The new auth flow went live without a feature flag. SSO failed for 17 minutes while the team scrambled for a fix.",
    prompt: "The new auth flow went live without a feature flag. SSO failed for 17 minutes while the team scrambled for a fix."
  },
  {
    to: "Taylor Morales",
    subject: "<span style='margin-right: 2px; font-style: italic; color: black; text-decoration: line-through; text-decoration-color: red;'>Double</span> Triple Charged",
    content: "A late-night deploy corrupted billing state, and kept issuing charges until <span class='hidden md:inline'>customers flagged the issue</span><span class='md:hidden'> the next morning</span>.",
    prompt: "A late-night deploy corrupted billing state, and kept issuing charges until customers flagged the issue. Some customers even got charged 3+ times."
  }
]