EXAMPLE_EMAILS = [
  {
    to: "Alex Shaw",
    subject: "N+1 queries explained in 30 seconds",
    content: "One query quietly explodes into hundreds. This pattern hides in loops, and often won’t show up until we hit real traffic...",
    prompt: "we took production down for 8 minutes (due to forgetting to add a DB index)"
  },
  {
    to: "Taylor Morales",
    subject: "Survive now, scale later",
    content: "Premature optimization is a luxury. At this stage, fast feedback and real usage matter more than perfect infra. Make it work — then make it better.",
    prompt: "built a queueing system to support 100x load before validating demand"
  },
  {
    to: "Casey Patel",
    subject: "The rollback failed. Now what?",
    content: "If your disaster recovery plan isn't tested, it's not real. Break-glass deploys need their own playbook.",
    prompt: "hotfix made things worse, rollback also failed"
  }
]