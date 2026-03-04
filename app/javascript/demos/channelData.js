/**
 * Demo channel data for the conversation UI
 * This is sample data - in production, channels would come from an API
 *
 * Shape matches ConversationContext:
 * - uuid: unique identifier used in URLs and API calls
 * - name: display name (can repeat across users)
 * - unreadCount, isMuted, isPrivate: UI state
 * - messages, messagesLoading: set by context provider
 */

export const DEMO_CHANNELS = [
  { uuid: 'backpressure', id: 'backpressure', name: 'Backpressure' },
  { uuid: 'caching', id: 'caching', name: 'Caching' },
  { uuid: 'circuit-breakers', id: 'circuit-breakers', name: 'Circuit Breakers' },
  { uuid: 'clock-skew', id: 'clock-skew', name: 'Clock Skew' },
  { uuid: 'connection-pooling', id: 'connection-pooling', name: 'Connection Pooling' },
  { uuid: 'consensus', id: 'consensus', name: 'Consensus' },
  { uuid: 'disaster-recovery', id: 'disaster-recovery', name: 'Disaster Recovery' },
  { uuid: 'dns', id: 'dns', name: 'DNS' },
  { uuid: 'event-ordering', id: 'event-ordering', name: 'Event Ordering' },
  { uuid: 'fanout', id: 'fanout', name: 'Fanout' },
  { uuid: 'hot-keys', id: 'hot-keys', name: 'Hot Keys' },
  { uuid: 'iam', id: 'iam', name: 'IAM' },
  { uuid: 'idempotency', id: 'idempotency', name: 'Idempotency' },
  { uuid: 'load-balancing', id: 'load-balancing', name: 'Load Balancing' },
  { uuid: 'network-partitions', id: 'network-partitions', name: 'Network Partitions' },
  { uuid: 'partial-failure', id: 'partial-failure', name: 'Partial Failure' },
  { uuid: 'partitioning', id: 'partitioning', name: 'Partitioning' },
  { uuid: 'queues', id: 'queues', name: 'Queues' },
  { uuid: 'rate-limiting', id: 'rate-limiting', name: 'Rate Limiting' },
  { uuid: 'replication', id: 'replication', name: 'Replication' },
  { uuid: 'resource-exhaustion', id: 'resource-exhaustion', name: 'Resource Exhaustion' },
  { uuid: 'retries', id: 'retries', name: 'Retries' },
  { uuid: 'service-discovery', id: 'service-discovery', name: 'Service Discovery' },
  { uuid: 'thundering-herd', id: 'thundering-herd', name: 'Thundering Herd' },
  { uuid: 'timeouts', id: 'timeouts', name: 'Timeouts' },
  { uuid: 'transactions', id: 'transactions', name: 'Transactions' },
]

export const DEFAULT_CHANNEL_ID = 'dns'