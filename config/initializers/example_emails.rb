EXAMPLE_EMAILS = [
  {
    to: "Alex Shaw",
    subject: "N+1 queries explained in 30 seconds",
    content: "One query quietly explodes into hundreds. This pattern hides in loops, and often won’t show up until we hit real traffic...",
    prompt: "we took production down for 8 minutes (due to forgetting to add a DB index)"
  },
  {
    to: "Taylor Morales",
    subject: "Flaky tests cost more than you think",
    content: "If a test fails for the wrong reason, we learn to ignore it — until we ignore the right failures too. Flaky tests kill trust in CI.",
    prompt: "team ignoring flaky CI failures, and let real bug ship to prod"
  },
  {
    to: "Casey Patel",
    subject: "Is it a bug, or a new feature?",
    content: "Bug reports that ask for behavior no one agreed to are product creep in disguise. Here are some tips to handle that.",
    prompt: "treating bugs as opportunity for scope creep"
  }
]