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
  { uuid: 'access-control', id: 'access-control', name: 'Access Control' },
  { uuid: 'backpressure', id: 'backpressure', name: 'Backpressure' },
  { uuid: 'caching', id: 'caching', name: 'Caching' },
  { uuid: 'capacity-planning', id: 'capacity-planning', name: 'Capacity Planning' },
  { uuid: 'causality', id: 'causality', name: 'Causality' },
  { uuid: 'circuit-breakers', id: 'circuit-breakers', name: 'Circuit Breakers' },
  { uuid: 'connection-pooling', id: 'connection-pooling', name: 'Connection Pooling' },
  { uuid: 'consensus', id: 'consensus', name: 'Consensus' },
  { uuid: 'disaster-recovery', id: 'disaster-recovery', name: 'Disaster Recovery' },
  { uuid: 'dns', id: 'dns', name: 'DNS' },
  { uuid: 'idempotency', id: 'idempotency', name: 'Idempotency' },
  { uuid: 'load-balancing', id: 'load-balancing', name: 'Load Balancing' },
  { uuid: 'migrations', id: 'migrations', name: 'Migrations' },
  { uuid: 'partitioning', id: 'partitioning', name: 'Partitioning' },
  { uuid: 'queues', id: 'queues', name: 'Queues' },
  { uuid: 'replication', id: 'replication', name: 'Replication' },
  { uuid: 'retries', id: 'retries', name: 'Retries' },
  { uuid: 'service-discovery', id: 'service-discovery', name: 'Service Discovery' },
  { uuid: 'slos', id: 'slos', name: 'SLOs' },
  { uuid: 'transactions', id: 'transactions', name: 'Transactions' },
]

export const DEFAULT_CHANNEL_ID = 'dns'