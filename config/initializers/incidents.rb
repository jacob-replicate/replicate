INCIDENTS = [
  {
    "prompt" => "An IAM audit log shows a service account executed admin actions in production using a token tied to a session already marked expired. The application still trusted the role claim in that token instead of enforcing session validity or scope checks. No approval workflow or ticket was linked, leaving unauthorized admin changes in audit trails and raising concerns about replayed or stale tokens being accepted across critical systems. Other internal tools accepted the same stale token, indicating trust boundaries were shared across environments.",
    "subject" => "Expired token granted unauthorized admin in production"
  },
  {
    "prompt" => "During peak traffic, the identity provider went down. Instead of failing closed, the application exposed a legacy public login path tied to a local user table. Dormant admin accounts that were never fully offboarded could still authenticate there, bypassing SSO and MFA. Audit logs now show privileged actions executed through this fallback path, raising concerns that external actors could have exploited it.",
    "subject" => "Legacy login page came back during SSO outage, bypassing MFA"
  },
  {
    "prompt" => "A background worker crashed midway through persisting a company’s monthly customer credit card charges. When it restarted, the task was retried by the job queue, which had no awareness of the partial write. The worker crashed again multiple times overnight, each time reprocessing the same task from scratch. Customers were charged two to four times depending on retry timing. The system lacked idempotency keys, write barriers, or deduplication safeguards — at-most-once semantics were completely absent. Finance teams didn’t notice the spike immediately, and the issue was first surfaced by a support ticket from a confused customer: 'Why was I charged four times?'",
    "subject" => "Invoicing job crashed. The retry issued duplicate charges to every customer."
  },
  {
    "prompt" => "During peak traffic, a downstream dependency began returning 500 errors. Instead of backing off, application workers retried in tight loops, flooding the message queue with duplicate requests. The retry storm overwhelmed the queueing system, caused dead-letter queues to overflow with poison messages, and spiked CPU and memory across multiple services. The customer dashboard began returning 503s and eventually failed entirely. The incident lasted 42 minutes before circuit breakers tripped and autoscaling recovered throughput. No alerts fired until the queue system breached resource thresholds, delaying detection across the board.",
    "subject" => "Retry storm killed the customer dashboard during peak traffic"
  },
  {
    "prompt" => "A SaaS employee accessed a customer-facing page while logged in with elevated staff permissions. The page included admin controls and sensitive data hidden behind 'if current_user.employee?'. The CDN cached that response without including auth headers in the cache key. Real customers later received the cached admin view of their own accounts. Attempts to purge the cache failed to fully clear stale entries, and multiple exposures were confirmed before the issue was contained.",
    "subject" => "CDN cached admin view and exposed it to users"
  },
  {
    "prompt" => "A customer exported a CSV report and received records from a completely different organization. The reporting query used a JOIN that silently failed to apply the expected tenant scoping logic under specific query parameter combinations. The ORM auto-generated the SQL but skipped the WHERE clause due to a polymorphic association edge case. Since the endpoint cached the full export by URL, the incorrect results were reused across multiple customers until anomaly detection in the SIEM flagged irregular access patterns. The customer had already downloaded the file.",
    "subject" => "Customer saw another org's data in CSV export"
  }
]