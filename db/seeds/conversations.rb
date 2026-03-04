# frozen_string_literal: true

# Conversation template seeds
# Each template represents a complete incident scenario that users can explore

puts "Seeding conversation templates..."

# =============================================================================
# 1. Database Deadlock Incident
# =============================================================================
deadlock_convo = Conversation.create!(
  topic: "connection-pooling",
  template: true
)

deadlock_messages = [
  {
    sequence: 1,
    author_name: "maya",
    author_avatar: "/profile-photo-3.jpg",
    components: [
      { type: "text", content: "just got paged — connection pool is spiking hard. sitting at 98% used on orders-db-primary" }
    ]
  },
  {
    sequence: 2,
    author_name: "maya",
    author_avatar: "/profile-photo-3.jpg",
    components: [
      { type: "text", content: "taking IC. @daniel can you pull up the connection metrics? seeing `max_connections=50` but we should have headroom" }
    ]
  },
  {
    sequence: 3,
    author_name: "daniel",
    author_avatar: "/profile-photo-2.jpg",
    components: [
      { type: "text", content: "on it — pulling grafana now" }
    ]
  },
  {
    sequence: 4,
    author_name: "alex",
    author_avatar: "/profile-photo-1.jpg",
    components: [
      { type: "text", content: "anything I can help with?" }
    ]
  },
  {
    sequence: 5,
    author_name: "maya",
    author_avatar: "/profile-photo-3.jpg",
    components: [
      { type: "text", content: "alex check if this is isolated to orders or if payments is affected too" }
    ]
  },
  {
    sequence: 6,
    author_name: "daniel",
    author_avatar: "/profile-photo-2.jpg",
    components: [
      { type: "text", content: "found it — connection acquire time spiking. looks like queries are hanging and never returning connections to the pool" },
      {
        type: "code",
        language: "sql",
        content: "-- active connections by state\nSELECT state, count(*), max(now() - query_start) as max_duration\nFROM pg_stat_activity WHERE datname = 'orders'\nGROUP BY state;\n\n state  | count |  max_duration\n--------+-------+----------------\n active |    47 | 00:04:23.445   -- these should be milliseconds\n idle   |     3 | 00:00:01.234"
      }
    ]
  },
  {
    sequence: 7,
    author_name: "alex",
    author_avatar: "/profile-photo-1.jpg",
    components: [
      { type: "text", content: "payments is fine, but I found something weird — someone added a new SELECT FOR UPDATE yesterday that's taking row locks" },
      {
        type: "diff",
        filename: "internal/orders/repository.go",
        lines: [
          { type: "context", text: "func (r *Repository) GetOrderForProcessing(ctx context.Context, id string) (*Order, error) {" },
          { type: "remove", text: "    return r.db.GetOrder(ctx, id)" },
          { type: "add", text: "    // Lock row to prevent double-processing" },
          { type: "add", text: "    return r.db.QueryRow(ctx, `SELECT * FROM orders WHERE id = $1 FOR UPDATE`, id)" },
          { type: "context", text: "}" }
        ]
      }
    ]
  },
  {
    sequence: 8,
    author_name: "daniel",
    author_avatar: "/profile-photo-2.jpg",
    components: [
      { type: "text", content: "oh no... FOR UPDATE with no timeout will wait forever for the lock" }
    ]
  },
  {
    sequence: 9,
    author_name: "alex",
    author_avatar: "/profile-photo-1.jpg",
    components: [
      { type: "text", content: "and if multiple workers try to process the same order..." }
    ]
  },
  {
    sequence: 10,
    author_name: "daniel",
    author_avatar: "/profile-photo-2.jpg",
    components: [
      { type: "text", content: "deadlock city 💀" }
    ]
  },
  {
    sequence: 11,
    author_name: "maya",
    author_avatar: "/profile-photo-3.jpg",
    components: [
      { type: "text", content: "confirmed — we have 23 transactions waiting on each other. classic deadlock pattern" },
      {
        type: "code",
        language: "sql",
        content: "-- blocked queries waiting on locks\nSELECT blocked.pid, blocked.query, blocking.pid as blocking_pid\nFROM pg_stat_activity blocked\nJOIN pg_locks bl ON bl.pid = blocked.pid\nJOIN pg_locks l ON l.relation = bl.relation AND l.pid != bl.pid\nJOIN pg_stat_activity blocking ON l.pid = blocking.pid\nWHERE NOT bl.granted;"
      }
    ]
  },
  {
    sequence: 12,
    author_name: "daniel",
    author_avatar: "/profile-photo-2.jpg",
    components: [
      { type: "text", content: "options: (1) kill the stuck queries and rollback, (2) add NOWAIT or SKIP LOCKED to the query, (3) revert the commit entirely" },
      { type: "text", content: "I'd vote revert — the FOR UPDATE approach needs a proper queue, not row locking" }
    ]
  },
  {
    sequence: 13,
    author_name: "alex",
    author_avatar: "/profile-photo-1.jpg",
    components: [
      { type: "text", content: "agreed — I can have the revert ready in 2 min" }
    ]
  },
  {
    sequence: 14,
    author_name: "maya",
    author_avatar: "/profile-photo-3.jpg",
    components: [
      { type: "text", content: "do it. daniel can you kill the stuck connections so we recover faster?" }
    ]
  },
  {
    sequence: 15,
    author_name: "daniel",
    author_avatar: "/profile-photo-2.jpg",
    components: [
      { type: "text", content: "already on it" }
    ]
  },
  {
    sequence: 16,
    author_name: "daniel",
    author_avatar: "/profile-photo-2.jpg",
    components: [
      { type: "text", content: "killed 23 stuck connections. pool is recovering" },
      {
        type: "code",
        language: "sql",
        content: "SELECT pg_terminate_backend(pid) \nFROM pg_stat_activity \nWHERE state = 'active' \n  AND query_start < now() - interval '1 minute'\n  AND datname = 'orders';\n\n-- 23 connections terminated"
      }
    ]
  },
  {
    sequence: 17,
    author_name: "maya",
    author_avatar: "/profile-photo-3.jpg",
    components: [
      { type: "text", content: "revert is deployed, pool is back to normal — down to 12 active connections now. @oncall marking resolved but we need a proper fix for the double-processing issue" }
    ]
  },
  {
    sequence: 18,
    author_name: "maya",
    author_avatar: "/profile-photo-3.jpg",
    components: [
      { type: "text", content: "created JIRA-4521 for the proper fix. @alex can you add a Datadog monitor for duplicate order IDs in the meantime?" }
    ]
  },
  {
    sequence: 19,
    author_name: "alex",
    author_avatar: "/profile-photo-1.jpg",
    components: [
      { type: "text", content: "on it. will alert if we see any order_id processed more than once in a 5 min window" }
    ]
  },
  {
    sequence: 20,
    author_name: "daniel",
    author_avatar: "/profile-photo-2.jpg",
    components: [
      { type: "text", content: "for the postmortem — the real issue is we're using database locks for job coordination. should've been a proper queue from day one" }
    ]
  },
  {
    sequence: 21,
    is_system: true,
    components: [
      {
        type: "multiple_choice",
        options: [
          { id: "a", thought: "Keep using row locks, but switch to SKIP LOCKED", message: "for the follow-up ticket — we could use SKIP LOCKED instead of FOR UPDATE. that way workers skip rows that are already being processed instead of blocking" },
          { id: "b", thought: "Introduce a distributed lock service (Redis/Zookeeper)", message: "thinking we need a distributed lock here — Redis or ZK. database row locks aren't meant for this kind of coordination" },
          { id: "c", thought: "Move job coordination into a proper queue with delivery guarantees", message: "this needs a proper job queue with exactly-once semantics. SQS FIFO or something similar — row locking for job coordination is always going to be fragile" }
        ]
      }
    ]
  }
]

deadlock_messages.each do |msg_data|
  message = deadlock_convo.messages.create!(
    sequence: msg_data[:sequence],
    author_name: msg_data[:author_name],
    author_avatar: msg_data[:author_avatar],
    is_system: msg_data[:is_system] || false
  )

  msg_data[:components].each_with_index do |comp_data, idx|
    message.components.create!(
      position: idx,
      data: comp_data
    )
  end
end

puts "  ✓ Database Deadlock Incident (#{deadlock_convo.messages.count} messages)"

# =============================================================================
# 2. Kafka Hot Partition Incident (Cold Case)
# =============================================================================
partition_convo = Conversation.create!(
  topic: "partitioning",
  template: true
)

partition_messages = [
  {
    sequence: 1,
    author_name: "alex",
    author_avatar: "/profile-photo-1.jpg",
    components: [
      { type: "text", content: "events service latency spiking hard — p99 is at 2847ms, completely through the roof" }
    ]
  },
  {
    sequence: 2,
    author_name: "maya",
    author_avatar: "/profile-photo-3.jpg",
    components: [
      { type: "text", content: "taking IC. @daniel what does the partition distribution look like? I'm seeing uneven load on the Kafka dashboard" }
    ]
  },
  {
    sequence: 3,
    author_name: "daniel",
    author_avatar: "/profile-photo-2.jpg",
    components: [
      { type: "text", content: "yep, we have a hot partition. partition 7 is getting hammered while the others are basically idle" },
      {
        type: "code",
        language: "text",
        content: "Partition | Events/sec | Lag    | Consumer\n----------|------------|--------|----------\n    0     |     124    |    2   | consumer-1\n    1     |      98    |    0   | consumer-2\n    2     |     156    |    4   | consumer-3\n    3     |     112    |    1   | consumer-4\n    4     |     134    |    3   | consumer-5\n    5     |      89    |    0   | consumer-6\n    6     |     145    |    2   | consumer-7\n    7     |  12,847    | 34,291 | consumer-8  ← hot partition\n    8     |     167    |    5   | consumer-9\n    9     |     103    |    1   | consumer-10"
      }
    ]
  },
  {
    sequence: 4,
    author_name: "alex",
    author_avatar: "/profile-photo-1.jpg",
    components: [
      { type: "text", content: "whoa, partition 7 has 100x the traffic. what's the partition key?" }
    ]
  },
  {
    sequence: 5,
    author_name: "daniel",
    author_avatar: "/profile-photo-2.jpg",
    components: [
      { type: "text", content: "user_id — we partition by user to keep all events for a user on the same consumer for ordering" }
    ]
  },
  {
    sequence: 6,
    author_name: "alex",
    author_avatar: "/profile-photo-1.jpg",
    components: [
      { type: "text", content: "found it — Acme Corp's integration went live yesterday. they're pushing 12k events/sec through user_id `acme_service_account`" },
      {
        type: "code",
        language: "sql",
        content: "SELECT user_id, count(*) as events_last_hour\nFROM events \nWHERE created_at > now() - interval '1 hour'\nGROUP BY user_id\nORDER BY events_last_hour DESC\nLIMIT 5;\n\n     user_id          | events_last_hour\n----------------------+------------------\n acme_service_account |       46,123,847\n user_8847123         |           12,445\n user_2234891         |            8,234\n user_9912834         |            6,122\n user_4456721         |            5,891"
      }
    ]
  },
  {
    sequence: 7,
    author_name: "maya",
    author_avatar: "/profile-photo-3.jpg",
    components: [
      { type: "text", content: "one user is 99.9% of traffic on that partition. classic hot key problem" }
    ]
  },
  {
    sequence: 8,
    author_name: "daniel",
    author_avatar: "/profile-photo-2.jpg",
    components: [
      { type: "text", content: "we only have 10 partitions — let me bump it to 100. that should spread the load better, and I'll add more consumers to match" }
    ]
  },
  {
    sequence: 9,
    author_name: "alex",
    author_avatar: "/profile-photo-1.jpg",
    components: [
      { type: "text", content: "will that actually help? same user_id will still hash to one partition" }
    ]
  },
  {
    sequence: 10,
    author_name: "daniel",
    author_avatar: "/profile-photo-2.jpg",
    components: [
      { type: "text", content: "true but with more partitions we get better overall distribution — reduces the probability any single partition becomes a bottleneck" }
    ]
  },
  {
    sequence: 11,
    author_name: "maya",
    author_avatar: "/profile-photo-3.jpg",
    components: [
      { type: "text", content: "let's do it. @daniel go ahead with the partition expansion. I'll coordinate with Acme to see if they can rate limit on their end while we scale up" }
    ]
  },
  {
    sequence: 12,
    author_name: "daniel",
    author_avatar: "/profile-photo-2.jpg",
    components: [
      { type: "text", content: "partition expansion complete — 100 partitions now, spun up 50 more consumers. lag is clearing" },
      {
        type: "code",
        language: "bash",
        content: "$ kafka-reassign-partitions.sh --execute \\\n    --reassignment-json-file expand-to-100.json\n\nPartition reassignment completed successfully.\n\n$ kubectl scale deployment events-consumer --replicas=50\ndeployment.apps/events-consumer scaled"
      }
    ]
  },
  {
    sequence: 13,
    author_name: "alex",
    author_avatar: "/profile-photo-1.jpg",
    components: [
      { type: "text", content: "latency recovering — p99 down to 180ms and dropping. Acme also said they can batch their events instead of sending individually which should help" }
    ]
  },
  {
    sequence: 14,
    author_name: "maya",
    author_avatar: "/profile-photo-3.jpg",
    components: [
      { type: "text", content: "perfect, marking this resolved. good work everyone 🎉" }
    ]
  },
  {
    sequence: 15,
    author_name: "daniel",
    author_avatar: "/profile-photo-2.jpg",
    components: [
      { type: "text", content: "filed the postmortem. root cause was insufficient partitions for the scale of our enterprise customers. we're in a better spot now with 100 partitions and autoscaling consumers" }
    ]
  },
  {
    sequence: 16,
    is_system: true,
    components: [
      {
        type: "multiple_choice",
        options: [
          { id: "a", thought: "we never modeled asymmetric user growth. partitions don't fix hot accounts", message: "we never modeled asymmetric user growth. partitions don't fix hot accounts" },
          { id: "b", thought: "there's no backpressure. we find out a partition is overloaded after it's too late", message: "there's no backpressure. we find out a partition is overloaded after it's too late" },
          { id: "c", thought: "the partition key is wrong. user_id guarantees this happens again for any high-volume account", message: "the partition key is wrong. user_id guarantees this happens again for any high-volume account" }
        ]
      }
    ]
  }
]

partition_messages.each do |msg_data|
  message = partition_convo.messages.create!(
    sequence: msg_data[:sequence],
    author_name: msg_data[:author_name],
    author_avatar: msg_data[:author_avatar],
    is_system: msg_data[:is_system] || false
  )

  msg_data[:components].each_with_index do |comp_data, idx|
    message.components.create!(
      position: idx,
      data: comp_data
    )
  end
end

puts "  ✓ Kafka Hot Partition Incident (#{partition_convo.messages.count} messages)"

# =============================================================================
# 3. Terraform Drift / Replication Lag Incident
# =============================================================================
replication_convo = Conversation.create!(
  topic: "replication",
  template: true
)

replication_messages = [
  {
    sequence: 1,
    author_name: "daniel",
    author_avatar: "/profile-photo-2.jpg",
    components: [
      { type: "text", content: "seeing weird data on the read replicas — customers reporting stale inventory counts. writes look fine on primary" }
    ]
  },
  {
    sequence: 2,
    author_name: "maya",
    author_avatar: "/profile-photo-3.jpg",
    components: [
      { type: "text", content: "taking IC. @alex can you check replication lag in CloudWatch? I'll look at the replica status" }
    ]
  },
  {
    sequence: 3,
    author_name: "alex",
    author_avatar: "/profile-photo-1.jpg",
    components: [
      { type: "text", content: "lag is through the roof — replica-2 is 847 seconds behind. replica-1 is at 12 seconds which is borderline acceptable" }
    ]
  },
  {
    sequence: 4,
    author_name: "maya",
    author_avatar: "/profile-photo-3.jpg",
    components: [
      { type: "text", content: "that explains the stale reads. pulling up the replica configs — something's off" }
    ]
  },
  {
    sequence: 5,
    author_name: "daniel",
    author_avatar: "/profile-photo-2.jpg",
    components: [
      { type: "text", content: "found it. replica-2 is running on db.r5.large while replica-1 is db.r5.2xlarge. the small instance can't keep up with the write throughput" },
      {
        type: "code",
        language: "bash",
        content: "$ aws rds describe-db-instances --query 'DBInstances[*].[DBInstanceIdentifier,DBInstanceClass]'\n[\n  [\"prod-primary\", \"db.r5.4xlarge\"],\n  [\"prod-replica-1\", \"db.r5.2xlarge\"],\n  [\"prod-replica-2\", \"db.r5.large\"]    # <-- undersized\n]"
      }
    ]
  },
  {
    sequence: 6,
    author_name: "alex",
    author_avatar: "/profile-photo-1.jpg",
    components: [
      { type: "text", content: "wait how did that happen? terraform should have them all at 2xlarge" }
    ]
  },
  {
    sequence: 7,
    author_name: "maya",
    author_avatar: "/profile-photo-3.jpg",
    components: [
      { type: "text", content: "running terraform plan now... yep, drift detected. someone manually resized replica-2 in the console and never updated the tf" },
      {
        type: "code",
        language: "hcl",
        content: "# terraform plan output\n~ resource \"aws_db_instance\" \"replica_2\" {\n    ~ instance_class = \"db.r5.large\" -> \"db.r5.2xlarge\"\n    # (12 unchanged attributes hidden)\n  }\n\nPlan: 0 to add, 1 to change, 0 to destroy."
      }
    ]
  },
  {
    sequence: 8,
    author_name: "daniel",
    author_avatar: "/profile-photo-2.jpg",
    components: [
      { type: "text", content: "git blame says the console change was made 3 weeks ago during the last incident. we were firefighting and someone downsized it \"temporarily\" to test something" }
    ]
  },
  {
    sequence: 9,
    author_name: "alex",
    author_avatar: "/profile-photo-1.jpg",
    components: [
      { type: "text", content: "classic. temporary changes have a way of becoming permanent" }
    ]
  },
  {
    sequence: 10,
    author_name: "maya",
    author_avatar: "/profile-photo-3.jpg",
    components: [
      { type: "text", content: "applying terraform now to resize replica-2. this will trigger a reboot but lag should recover within 10-15 min after" }
    ]
  },
  {
    sequence: 11,
    author_name: "daniel",
    author_avatar: "/profile-photo-2.jpg",
    components: [
      { type: "text", content: "in the meantime I'll update the load balancer to route all reads to replica-1. at least we'll have consistent data while replica-2 catches up" },
      {
        type: "code",
        language: "hcl",
        content: "# Temporarily route all traffic to healthy replica\nresource \"aws_lb_target_group_attachment\" \"read_replica\" {\n  target_group_arn = aws_lb_target_group.read_replicas.arn\n  target_id        = aws_db_instance.replica_1.id\n  port             = 5432\n}\n\n# replica_2 removed until caught up"
      }
    ]
  },
  {
    sequence: 12,
    author_name: "alex",
    author_avatar: "/profile-photo-1.jpg",
    components: [
      { type: "text", content: "terraform apply completed. replica-2 is rebooting with the correct instance size" }
    ]
  },
  {
    sequence: 13,
    author_name: "maya",
    author_avatar: "/profile-photo-3.jpg",
    components: [
      { type: "text", content: "replica-2 is back online and lag is dropping fast — down to 200 seconds already. should be caught up in a few minutes" }
    ]
  },
  {
    sequence: 14,
    author_name: "daniel",
    author_avatar: "/profile-photo-2.jpg",
    components: [
      { type: "text", content: "lag at 0 on both replicas. adding replica-2 back to the load balancer. marking incident resolved" }
    ]
  },
  {
    sequence: 15,
    author_name: "alex",
    author_avatar: "/profile-photo-1.jpg",
    components: [
      { type: "text", content: "for the postmortem — we need to talk about drift detection. this wouldn't have happened if we had terraform plan running on a schedule" }
    ]
  },
  {
    sequence: 16,
    is_system: true,
    components: [
      {
        type: "multiple_choice",
        options: [
          { id: "a", thought: "Add a CI job that runs terraform plan daily and alerts on drift", message: "we should add a CI job that runs terraform plan on a schedule — alert if there's any drift between state and reality" },
          { id: "b", thought: "Lock down console access and require all changes go through terraform", message: "the real fix is locking down console write access. all infra changes should go through terraform PRs — no exceptions during incidents" },
          { id: "c", thought: "Add replication lag alerting so we catch this faster next time", message: "we need better alerting on replication lag. if we'd been paged when lag exceeded 60 seconds, we would've caught this before customers noticed" }
        ]
      }
    ]
  }
]

replication_messages.each do |msg_data|
  message = replication_convo.messages.create!(
    sequence: msg_data[:sequence],
    author_name: msg_data[:author_name],
    author_avatar: msg_data[:author_avatar],
    is_system: msg_data[:is_system] || false
  )

  msg_data[:components].each_with_index do |comp_data, idx|
    message.components.create!(
      position: idx,
      data: comp_data
    )
  end
end

puts "  ✓ Terraform Drift Replication Incident (#{replication_convo.messages.count} messages)"

puts "\nSeeded #{Conversation.templates.count} conversation templates with #{Message.count} total messages."