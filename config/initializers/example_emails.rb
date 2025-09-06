EXAMPLE_EMAILS = [
  {
    to: "Alex Shaw",
    subject: "1-line \"fix\"<span style='padding: 0px 7px' class='text-red-600 inline-block'>&rarr;</span>3-day incident",
    content: "Staging credentials were accidentally rotated into production, triggering failures in downstream services.",
    prompt: "An engineer shipped a one-line 'fix' that accidentally rotated staging secrets into production, crashed the site, and triggered failures across lots of downstream services. This 1-line fix is going to take days to clean up."
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