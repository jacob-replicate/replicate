EXAMPLE_EMAILS = [
  {
    to: "Alex Shaw",
    subject: "N+1 queries in 30 seconds",
    content: "One query quietly explodes into hundreds. This pattern hides in loops, and usually only impacts production.",
    prompt: "shipped an N+1 query, and took down production for 6 minutes"
  },
  {
    to: "Casey Patel",
    subject: "Survive Now, Scale Later",
    content: "Premature optimization is a luxury. At our scale, fast feedback and real usage matter more than perfect infra.",
    prompt: "built a queueing system to support 100x load before validating demand"
  },
  {
    to: "Taylor Morales",
    subject: "The rollback failed. Now what?",
    content: "If our disaster recovery plan isn't tested, it isn't real. Break-glass deploys need their own playbook.",
    prompt: "hotfix made things worse, rollback also failed"
  }
]