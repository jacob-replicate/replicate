/**
 * Demo channel data for the conversation UI
 * This is sample data - in production, channels would come from an API
 *
 * Shape matches ConversationContext:
 * - uuid: unique identifier used in URLs and API calls
 * - name: display name (can repeat across users)
 * - lastReadMessageId: tracks read state (null = unread, matches last message = read)
 * - messages: stub message array for unread indicator to work
 * - messagesLoading: set by context provider
 */

// Helper to create a channel with a stub message for unread tracking
const channel = (id, name) => ({
  uuid: id,
  id,
  name,
  messages: [{ id: `${id}_stub` }],
  lastReadMessageId: `${id}_stub`, // starts as read
})

export const DEMO_CHANNELS = [
  channel('backpressure', 'Backpressure'),
  channel('caching', 'Caching'),
  channel('circuit-breakers', 'Circuit Breakers'),
  channel('clock-skew', 'Clock Skew'),
  channel('connection-pooling', 'Connection Pooling'),
  channel('consensus', 'Consensus'),
  channel('disaster-recovery', 'Disaster Recovery'),
  channel('dns', 'DNS'),
  channel('event-ordering', 'Event Ordering'),
  channel('fanout', 'Fanout'),
  channel('hot-keys', 'Hot Keys'),
  channel('iam', 'IAM'),
  channel('idempotency', 'Idempotency'),
  channel('load-balancing', 'Load Balancing'),
  channel('network-partitions', 'Network Partitions'),
  channel('partial-failure', 'Partial Failure'),
  channel('partitioning', 'Partitioning'),
  channel('queues', 'Queues'),
  channel('rate-limiting', 'Rate Limiting'),
  channel('replication', 'Replication'),
  channel('resource-exhaustion', 'Resource Exhaustion'),
  channel('retries', 'Retries'),
  channel('service-discovery', 'Service Discovery'),
  channel('thundering-herd', 'Thundering Herd'),
  channel('timeouts', 'Timeouts'),
  channel('transactions', 'Transactions'),
]

export const DEFAULT_CHANNEL_ID = 'dns'