class StaticController < ApplicationController
  def index
  end

  def terms
  end

  def privacy
    redirect_to "https://docs.google.com/document/d/1SZEi3VcuNtLCLhg44WaSDuNTfndmT9BqdF5-djxKEeM", allow_other_host: true
  end

  def billing
    @title = "Billing"
  end

  def demo
    return start_conversation(
      context: {
        conversation_type: :landing_demo,
        engineer_name: "Alex Shaw",
        first_name: "Alex",
        incident: example_incidents.sample
      },
      force_tos: true
    )
  end

  def coaching
    name = ["Alex Shaw", "Taylor Morales", "Casey Patel"].sample
    first_name = name.split.first

    return start_conversation(
      context: {
        conversation_type: :coaching,
        engineer_name: name,
        first_name: first_name,
        incident: example_incidents.sample
      },
      force_tos: true
    )
  end

  def security
    @title = "Security"
  end

  def how_it_works
  end

  def knowledge_gaps
    redirect_to "https://docs.google.com/document/d/1YSmtsZYZ6qJrTOv4raqOUcU2Q1YvrVTzlab9QjUFT50/edit", allow_other_host: true
  end

  private

  def example_incidents
    [
      "Late-night hotfix broke an invoicing job, and the rollback left customer data in a corrupted state.",
      "A feature flag rollout triggered unexpected writes, corrupting user preferences across environments.",
      "A background job retried failed payments indefinitely, silently charging some customers twice.",
      "A schema change removed a nullable column — and the next deploy crashed every signup.",
      "A stale config in staging masked a 503 loop in production for nearly 3 hours.",
      "A malformed webhook payload bypassed validation and poisoned the audit trail.",
      "The incident response bot went down with the same dependency it was meant to report on.",
      "A caching layer upgrade dropped all write-through logic — production data diverged within minutes.",
      "Rate limits were enforced globally, not per user — and a single customer blocked the entire API.",
      "A misconfigured health check caused a node rotation storm that degraded performance company-wide.",
      "A timezone bug in a cron expression delayed invoice generation by 12 hours, causing them to be off by one day.",
      "A read replica lag masked write failures — the team celebrated green dashboards for a week.",
      "Two teams renamed the same protobuf field in different services. Rollbacks didn't help.",
      "An observability agent upgrade exposed internal metadata over a public endpoint.",
      "A batch import script skipped rows with nulls — and nulls were the rows we cared about.",
      "A 'safe to retry' error surfaced on a non-idempotent endpoint, corrupting state on every retry.",
      "A metrics alert fired too early, masking the real issue: a slow leak in session expiration logic.",
      "A circuit breaker tripped for the wrong fallback — stale data got served as live inventory.",
      "A deploy skipped a migration. The app didn't crash, but the behavior drifted for weeks.",
      "The security team added a required header. Half the integrations broke silently.",
      "A rollback restored code, but not the associated IAM policy — every request now failed with 403.",
      "A database promotion failed mid-cutover — both replicas accepted writes for 9 minutes.",
      "An edge cache stored sensitive headers and replayed them across users.",
      "An expired certificate broke OAuth login for every enterprise customer.",
      "SSO callback responses weren't validated — users were logged in as admins.",
      "The primary key overflowed and started assigning duplicate IDs.",
      "A backup restore silently skipped one table — it took two weeks to notice.",
      "A Slack bot leaked production tokens to a shared channel.",
      "Staging secrets were used in production — and rotated automatically at midnight.",
      "A pagination loop DOSed the billing endpoint, breaking every invoice export job.",
      "The rollout script updated the wrong feature flag, shipping an unfinished workflow to prod.",
      "A queue retry storm overwhelmed the read replica and silently degraded performance.",
      "The search index lagged behind by 12 hours — nobody knew until a customer asked.",
      "CI ran against the wrong branch, and deployed staging code to production.",
      "The incident responder rebooted the wrong cluster — recovery took 2 hours longer.",
      "An unversioned config changed behavior between deploys and caused a data wipe.",
      "A roll-forward fixed the bug but introduced a worse one — and nobody rolled back.",
      "An alert fired during an on-call handoff and got lost in a Slack thread.",
      "Log truncation dropped the root cause of the SEV — it never made it to the postmortem.",
      "A test environment got promoted to production — it took down all customer access.",
      "An invalid IP whitelist locked the CEO out of the dashboard mid-outage.",
      "A firewall rule was updated without coordination — half of prod went dark.",
      "The failover region wasn't pre-warmed — the handoff timed out during the SEV.",
      "A GCP IAM role was deleted by a terraform drift fix — and no one noticed until Monday.",
      "The metrics dashboard showed 99.9% uptime — because the health check always returned 200.",
      "An analytics SDK flooded the network with retries — it masked actual outages.",
      "The API gateway dropped all DELETE requests due to a malformed regex.",
      "A DNS misconfiguration routed staging traffic into production."
    ]
  end
end