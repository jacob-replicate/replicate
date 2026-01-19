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
    description: 'The gap between "deploy finished" and "traffic actually shifted" is where requests die waiting for registries to catch up.',
    generation_intent: ''
  },
  'load-balancing' => {
    name: 'Load Balancing',
    description: 'Traffic looks balanced until one backend gets all the expensive requests and the health check still says it\'s fine.',
    generation_intent: ''
  },
  'edge' => {
    name: 'Edge',
    description: 'Your CDN config is probably caching things it shouldn\'t or missing things it should, and you won\'t notice until it matters.',
    generation_intent: ''
  },
  'rate-limiting' => {
    name: 'Rate Limiting',
    description: 'Without limits, one bad client can take down your whole system, and you\'ll spend the incident figuring out who to block.',
    generation_intent: ''
  },

  # === NETWORK SECURITY ===
  'network-security' => {
    name: 'Network Segmentation',
    description: 'Flat networks let attackers move laterally after they get in, turning one compromised host into access to everything.',
    generation_intent: ''
  },
  'encryption' => {
    name: 'Encryption',
    description: 'Expired certs cause more outages than attackers do.',
    generation_intent: ''
  },

  # === IDENTITY & ACCESS ===
  'identity' => {
    name: 'Service Identity',
    description: 'If your services authenticate with shared secrets, you can\'t revoke access to one without rotating credentials everywhere.',
    generation_intent: ''
  },

  # === SECURITY OPERATIONS ===
  'threat-detection' => {
    name: 'Threat Detection',
    description: 'You won\'t notice the breach until someone else tells you about it, because your alerts are tuned for noise, not signal.',
    generation_intent: ''
  },
  'security-incidents' => {
    name: 'Security Incidents',
    description: 'The breach itself is survivable; the response is what determines whether you contain it in hours or explain it for months.',
    generation_intent: ''
  },
  'compliance' => {
    name: 'Compliance',
    description: 'Auditors ask for evidence you probably don\'t have unless you built collection into the system from day one.',
    generation_intent: ''
  },
  'supply-chain' => {
    name: 'Supply Chain Security',
    description: 'Your dependencies have dependencies, and somewhere in that tree is a package that hasn\'t been updated since 2019.',
    generation_intent: ''
  },

  # === DATA CONSISTENCY ===
  'consistency' => {
    name: 'Consistency',
    description: 'Your read might not see your write, and that breaks more user-facing assumptions than most engineers expect.',
    generation_intent: ''
  },
  'consensus' => {
    name: 'Distributed Consensus',
    description: 'Split-brain happens when nodes disagree about who\'s in charge, and both sides keep accepting writes.',
    generation_intent: ''
  },
  'idempotency' => {
    name: 'Idempotency',
    description: 'Retries happen. If your code isn\'t idempotent, you\'ll run it twice. If your code isn\'t idempotent, you\'ll run it twice.',
    generation_intent: ''
  },

  # === DATABASE OPERATIONS ===
  'database-ops' => {
    name: 'Database Internals',
    description: 'Slow queries usually aren\'t the query\'s fault. It\'s the missing index, bloated table, or lock you didn\'t know about.',
    generation_intent: ''
  },
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
    name: 'Backup Recovery',
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
    description: 'Flags let you ship code without shipping risk, until you have a thousand of them and nobody knows which ones matter.',
    generation_intent: ''
  },
  'config-management' => {
    name: 'Configuration Management',
    description: 'Staging never matches production no matter how hard you try, and the differences are where the bugs hide.',
    generation_intent: ''
  },

  # === CONTAINER ORCHESTRATION ===
  'containers' => {
    name: 'Container Fundamentals',
    description: 'Containers share the kernel with the host. The isolation you assume exists is a polite fiction enforced by cgroups.',
    generation_intent: ''
  },
  'orchestration' => {
    name: 'Orchestration',
    description: 'Scheduling is easy until every node claims it\'s full and your workload has nowhere to go.',
    generation_intent: ''
  },
  'container-runtime' => {
    name: 'Container Runtime',
    description: 'OOMKilled means you ran out of memory. CPU throttling means the kernel is lying to you about available compute.',
    generation_intent: ''
  },
  'stateful-workloads' => {
    name: 'Stateful Workloads',
    description: 'Orchestrators assume your containers are disposable, but your database can\'t just restart somewhere else.',
    generation_intent: ''
  },

  # === RELIABILITY ===
  'capacity' => {
    name: 'Capacity Management',
    description: 'Autoscaling reacts to load, but by the time new instances are ready you\'ve already been dropping requests for minutes.',
    generation_intent: ''
  },
  'observability' => {
    name: 'Observability',
    description: 'Dashboards show you what you expected to break, not what actually broke, so the real problem isn\'t on any graph.',
    generation_intent: ''
  },
  'incidents' => {
    name: 'Incident Response',
    description: 'The first ten minutes of an incident determine whether it lasts one hour or six, and most teams waste them.',
    generation_intent: ''
  },
  'cost' => {
    name: 'Cost Optimization',
    description: 'Unused resources don\'t page anyone, so they stick around forever until someone finally looks at the bill.',
    generation_intent: ''
  }
}

# Use topic-specific description/intent if present; otherwise fall back to the previous generic template.
topics_data.each do |code, data|
  Topic.find_or_create_by!(code: code) do |t|
    t.name = data[:name]
    t.description = data[:description] || "Technical challenges and patterns related to #{data[:name].downcase} in distributed systems."
    t.generation_intent = data[:generation_intent] || "Explore failure modes, edge cases, and misconceptions around #{data[:name].downcase} in production systems."
  end
end