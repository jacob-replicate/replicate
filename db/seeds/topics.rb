# frozen_string_literal: true

# ---------- Topics ----------
# Organized by learning path: understand the platform → secure it → ship safely → keep it running
# ~25 topics, each broad enough to hold many experiences

topics_data = {
  # === TRAFFIC ===
  'dns' => {
    name: 'DNS',
    description: 'Most outages start here because everyone assumes name resolution just works, until a TTL expires wrong.',
    generation_intent: ''
  },
  'service-discovery' => {
    name: 'Service Discovery',
    description: 'The gap between "deploy finished" and "traffic shifted" is where requests die waiting for registries.',
    generation_intent: ''
  },
  'load-balancing' => {
    name: 'Load Balancing',
    description: 'Traffic looks balanced until one backend gets all the expensive requests and the health check still says it\'s fine.',
    generation_intent: ''
  },
  'edge' => {
    name: 'Edge',
    description: 'Your CDN config is probably caching wrong things or missing right ones, and you won\'t notice until it matters.',
    generation_intent: ''
  },
  'rate-limiting' => {
    name: 'Rate Limiting',
    description: 'Without limits, one bad client can take down your whole system while you scramble to figure out who to block.',
    generation_intent: ''
  },

  # === NETWORK SECURITY ===
  'network-segmentation' => {
    name: 'Network Segmentation',
    description: 'Flat networks let attackers move laterally, turning one compromised host into access to everything.',
    generation_intent: ''
  },
  'encryption' => {
    name: 'Encryption',
    description: 'Expired certs cause more outages than attackers do.',
    generation_intent: ''
  },


  # === SECURITY OPERATIONS ===
  'compliance' => {
    name: 'Compliance',
    description: 'Auditors ask for evidence you probably don\'t have unless you built collection into the system from day one.',
    generation_intent: ''
  },
  'supply-chain' => {
    name: 'Supply Chain Security',
    description: 'Your dependencies have dependencies, and somewhere in that tree is a package last updated in 2019.',
    generation_intent: ''
  },

  # === DATA CONSISTENCY ===
  'stale-reads' => {
    name: 'Stale Reads',
    description: 'Your read didn\'t see your write. The user refreshed and it looked like their action never happened.',
    generation_intent: ''
  },
  'consensus' => {
    name: 'Consensus',
    description: 'Split-brain is when nodes disagree about who\'s in charge and both sides keep accepting writes.',
    generation_intent: ''
  },
  'idempotency' => {
    name: 'Idempotency',
    description: 'Retries happen. If your code isn\'t idempotent, you\'ll run it twice. If your code isn\'t idempotent, you\'ll run it twice.',
    generation_intent: ''
  },
  'ordering' => {
    name: 'Ordering',
    description: 'Events arrived out of order and your system processed the delete before the create.',
    generation_intent: ''
  },
  'transactions' => {
    name: 'Transactions',
    description: 'The first write succeeded. The second failed. Now your data is half-committed and no one knows.',
    generation_intent: ''
  },

  # === DATABASE OPERATIONS ===
  'partitioning' => {
    name: 'Partitioning',
    description: 'Pick the wrong partition key and all your writes hit one shard while the rest of the cluster sits idle.',
    generation_intent: ''
  },
  'caching' => {
    name: 'Caching',
    description: 'Caches hide latency problems until they fail, then the database gets hit with two years of deferred load at once.',
    generation_intent: ''
  },
  'backups' => {
    name: 'Backups',
    description: 'Backups only matter if you\'ve actually tested the restore, under pressure, with someone watching.',
    generation_intent: ''
  },

  # === SHIPPING CHANGES ===
  'ci-cd' => {
    name: 'CI/CD',
    description: 'Fast deploys don\'t matter if you can\'t roll back faster, and most rollback buttons are never tested.',
    generation_intent: ''
  },
  'migrations' => {
    name: 'Schema Migrations',
    description: 'Rollback doesn\'t undo the data changes your migration already made, and the deploy after that assumes it did.',
    generation_intent: ''
  },
  'feature-flags' => {
    name: 'Feature Flags',
    description: 'Flags let you ship code without shipping risk, until you have a thousand and nobody knows which matter.',
    generation_intent: ''
  },
  'config-management' => {
    name: 'Configuration Management',
    description: 'Staging never matches production no matter how hard you try, and the differences are where the bugs hide.',
    generation_intent: ''
  },

  # === COMPUTE ===
  'resource-limits' => {
    name: 'Resource Limits',
    description: 'OOMKilled means you hit the wall. Throttled means you\'re being lied to about how much CPU you have.',
    generation_intent: ''
  },
  'scheduling' => {
    name: 'Scheduling',
    description: 'The platform decides where your code runs. When it picks wrong, you find out during the incident.',
    generation_intent: ''
  },
  'workload-isolation' => {
    name: 'Isolation',
    description: 'Workloads share more than you think. The boundary you trust is a polite fiction enforced by the kernel.',
    generation_intent: ''
  },
  'workload-state' => {
    name: 'Workload State',
    description: 'Stateless is easy to scale. Stateful is where your data lives. Confusing them is how you lose both.',
    generation_intent: ''
  },

  # === OBSERVABILITY ===
  'logging' => {
    name: 'Logging',
    description: 'You\'ll grep for the one log line that matters and find it was the one you didn\'t add.',
    generation_intent: ''
  },
  'metrics' => {
    name: 'Metrics',
    description: 'The dashboard was green the whole time. The problem was in a dimension you weren\'t slicing by.',
    generation_intent: ''
  },
  'tracing' => {
    name: 'Tracing',
    description: 'The request took 800ms but every span says 50ms. The gap is where your problem lives.',
    generation_intent: ''
  },
  'alerting' => {
    name: 'Alerting',
    description: 'The alert fired at 3am. It had been firing every night for months. No one remembered why.',
    generation_intent: ''
  },

  # === GOVERNANCE ===
  'iam' => {
    name: 'IAM',
    description: 'Someone has admin access who shouldn\'t. You\'ll find out when they leave or when the auditor does.',
    generation_intent: ''
  },
  'compliance' => {
    name: 'Compliance',
    description: 'Auditors ask for evidence you don\'t have unless you built collection into the system from day one.',
    generation_intent: ''
  },
  'cost-optimization' => {
    name: 'Cost Optimization',
    description: 'Unused resources don\'t page anyone, so they stick around forever until someone looks at the bill.',
    generation_intent: ''
  },
  'threat-detection' => {
    name: 'Threat Detection',
    description: 'You won\'t notice the breach until someone else tells you. Your alerts are tuned for noise, not signal.',
    generation_intent: ''
  },
}

# Use topic-specific description/intent if present; otherwise fall back to the previous generic template.
topics_data.each do |code, data|
  Topic.find_or_create_by!(code: code) do |t|
    t.name = data[:name]
    t.description = data[:description] || "Technical challenges and patterns related to #{data[:name].downcase} in distributed systems."
    t.generation_intent = data[:generation_intent] || "Explore failure modes, edge cases, and misconceptions around #{data[:name].downcase} in production systems."
  end
end