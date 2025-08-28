EMAIL_INCIDENTS = [
  {
    code: "sso-callbacks",
    report_header: "SSO callbacks were not validated",
    category: :authentication,
    prompt: "SSO callback responses weren't validated - users were logged in as admins.",
    subject_lines: [
      "SSO callback granted admin access without validation.",
      "Token reuse bypassed role verification in SSO.",
      "SSO redirect flow granted elevated access silently.",
      "Session binding skipped; admin login accepted anyway.",
      "Callback trust violated origin-based boundary."
    ]
  },
  {
    code: "retry-storm",
    report_header: "Retries amplified downstream saturation",
    category: :resilience,
    prompt: "A brief blip in a dependent service triggered retries from every instance - taking the whole region offline.",
    subject_lines: [
      "Retry logic multiplied pressure after minor outage.",
      "Backoff failed; saturation cascaded instantly.",
      "Safe retries triggered unsafe regional collapse.",
      "Circuit breaker tripped - but retries had already piled up.",
      "Graceful failover triggered a retry flood."
    ]
  },
  {
    code: "replica-lag",
    report_header: "Stale replica masked a failed write",
    category: :data_integrity,
    prompt: "A successful write appeared present when read from a replica - masking the failure and causing silent data loss.",
    subject_lines: [
      "Replica showed data that never reached primary.",
      "Read-after-write hit stale node, hid failure.",
      "Replica lag masked a rejected write.",
      "Secondary returned confirmation before consistency.",
      "Write visibility violated expected quorum behavior."
    ]
  },
  {
    code: "alert-fatigue",
    report_header: "Critical alert was ignored during a real SEV",
    category: :observability,
    prompt: "A real incident happened, but no one reacted because the critical alert fired too often to be trusted.",
    subject_lines: [
      "Critical alert fired - and was ignored on impact.",
      "Alert channel lost credibility before the SEV.",
      "Fatigued alerting disabled real-time response.",
      "High-signal alert buried by noise budget.",
      "Team missed SEV - alert matched usual false pattern."
    ]
  },
  {
    code: "ci-skip-tag",
    report_header: "CI bypass left broken build in prod",
    category: :supply_chain,
    prompt: "A broken test was force-pushed and tagged manually - CI passed due to misconfigured trust on tag pushes.",
    subject_lines: [
      "Tag bypassed CI and shipped untested changes.",
      "Trusted tag ran no tests before release.",
      "Tag trigger trusted stale pipeline state.",
      "CI skipped tests; tag shipped broken state.",
      "Git workflow let tagged failure bypass guardrail."
    ]
  },
  {
    code: "expired-jwt-cache",
    report_header: "JWT revocation cache failed open under load",
    category: :identity,
    prompt: "A cache eviction bug let expired JWTs validate for hours. No users noticed.",
    subject_lines: [
      "Expired tokens passed validation under cache pressure.",
      "Revocation cache missed expired JWTs silently.",
      "Token TTLs respected in theory, not in memory.",
      "Auth cache failures allowed long-dead sessions to persist.",
      "Idle auth infra ignored token expiry rules at scale."
    ]
  },
  {
    code: "cidr-wildcard",
    report_header: "A wildcard CIDR opened internal APIs to the internet",
    category: :networking,
    prompt: "An internal service was exposed externally due to a CIDR misconfig in the firewall - logs show it was scraped for hours.",
    subject_lines: [
      "Firewall rule exposed private API via wildcard.",
      "Misplaced CIDR widened network trust silently.",
      "Internal traffic rules leaked routes to internet.",
      "Service trusted 0.0.0.0 - no one noticed.",
      "Ingress config violated network boundary expectations."
    ]
  },
  {
    code: "bounced-webhook",
    report_header: "Webhooks silently failed due to missing HMAC checks",
    category: :integration,
    prompt: "A 3rd-party webhook endpoint silently ignored HMAC validation for months - spoofed payloads weren't detected.",
    subject_lines: [
      "Webhook skipped HMAC check without warning.",
      "Payload signature failed, delivery proceeded anyway.",
      "Endpoint bypassed validation guard, processed spoofed data.",
      "Expected HMAC header ignored due to handler bug.",
      "Webhooks trusted unsigned payloads for months."
    ]
  },
  {
    code: "prod-admin-shell",
    report_header: "Ephemeral admin access left a root shell open in prod",
    category: :access,
    prompt: "An engineer used a short-lived debug path to shell into prod. The session lingered for 3 hours with root access.",
    subject_lines: [
      "Root session persisted in prod after debug task ended.",
      "Short-lived shell lingered past expiration window.",
      "Debug access path kept prod door unlocked.",
      "Temporary root access became a standing session.",
      "Ephemeral privilege failed to self-expire."
    ]
  },
  {
    code: "secret-in-snapshot",
    report_header: "Plaintext credentials were captured in a debug snapshot",
    category: :observability,
    prompt: "A crash snapshot included full environment vars and a plaintext secret - it was auto-sent to a 3rd-party error tool.",
    subject_lines: [
      "Debug snapshot leaked secret to error tracking SaaS.",
      "Plaintext creds captured in crash dump by default.",
      "Error snapshot system broke containment boundary.",
      "Secrets escaped via observability pipeline.",
      "Fault handler exposed environment trust unintentionally."
    ]
  }
]