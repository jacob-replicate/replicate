EMAIL_INCIDENTS = [
  {
    "prompt" => "An IAM audit log shows a service account executed admin actions in production using a token tied to a session already marked expired. The application still trusted the role claim in that token instead of enforcing session validity or scope checks. No approval workflow or ticket was linked, leaving unauthorized admin changes in audit trails and raising concerns about replayed or stale tokens being accepted across critical systems.",
    "subject" => "Expired token granted unauthorized admin in production"
  },
  {
    "prompt" => "During peak traffic, the identity provider went down. Instead of failing closed, the application exposed a legacy public login path tied to a local user table. Dormant admin accounts that were never fully offboarded could still authenticate there, bypassing SSO and MFA. Audit logs now show privileged actions executed through this fallback path, raising concerns that external actors could have exploited it.",
    "subject" => "Legacy login page came back during SSO outage, bypassing MFA"
  },
  {
    "prompt" => "A background worker crashed midway through persisting a company's monthly customer credit card charges. When it restarted, the queue reprocessed the task without realizing a partial write had already occurred. Lots of customers were billed twice because the system lacked true at-most-once safeguards. Finance teams now see unexplained spikes in duplicate transactions. Zero idempotency.",
    "subject" => "Invoicing job crashed, double charging hundreds of customers"
  },
  {
    "prompt" => "A downstream dependency began returning 500 errors. Instead of backing off, workers retried requests in tight loops. Message queues filled rapidly, and dead-letter queues overflowed with poison messages. CPU and memory spiked across multiple services until circuit breakers finally tripped.",
    "subject" => "Unbounded retries crippled customer-facing systems"
  },
  {
    "prompt" => "Users reported seeing data belonging to other accounts. Investigation shows CDN caches returning responses without including authentication headers in the cache key. As a result, personalized or sensitive content was served across sessions. Purge attempts didn’t fully clear stale entries.",
    "subject" => "Cached personalized responses leaked between users"
  },
  {
    "prompt" => "A reporting endpoint assembled data with a JOIN that forgot to constrain by tenant. Under certain query parameters the ORM skipped the scoping clause, returning cross-tenant records. A cached response then amplified the blast radius until audit alerts caught the anomaly.",
    "subject" => "Customer saw another org's data in CSV export"
  }
]