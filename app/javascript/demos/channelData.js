/**
 * Demo channel data for the conversation UI
 * This is sample data - in production, channels would come from an API
 *
 * Shape matches ConversationContext:
 * - uuid: unique identifier used in URLs and API calls
 * - name: display name (can repeat across users)
 * - section: for grouping in sidebar
 * - unreadCount, isMuted, isPrivate: UI state
 * - messages, messagesLoading: set by context provider
 */

export const DEMO_CHANNELS = [
  // Active incidents (filtered by uuid prefix 'inc-')
  { uuid: 'inc-4521-cart-500s', id: 'inc-4521-cart-500s', name: 'Cart Service 500s', unreadCount: 0 },
  { uuid: 'inc-4519-redis-oom', id: 'inc-4519-redis-oom', name: 'Redis Cluster OOM', unreadCount: 3 },
  { uuid: 'inc-4517-payments-timeout', id: 'inc-4517-payments-timeout', name: 'Stripe Webhook Timeout', unreadCount: 0 },
  { uuid: 'inc-4515-dns-propagation', id: 'inc-4515-dns-propagation', name: 'DNS Propagation Delay', unreadCount: 0 },
  { uuid: 'inc-4513-kafka-lag', id: 'inc-4513-kafka-lag', name: 'Kafka Consumer Lag', unreadCount: 5 },
  { uuid: 'inc-4511-ssl-expiry', id: 'inc-4511-ssl-expiry', name: 'SSL Cert Expiry', unreadCount: 0 },
  // Code Review - PR discussions
  { uuid: 'pr-auth-refactor', id: 'pr-auth-refactor', name: 'OAuth2 Token Rotation', section: 'code-review', unreadCount: 0 },
  { uuid: 'pr-rate-limiter', id: 'pr-rate-limiter', name: 'Sliding Window Rate Limiter', section: 'code-review', unreadCount: 0 },
  { uuid: 'pr-db-migration', id: 'pr-db-migration', name: 'Zero Downtime Schema Migration', section: 'code-review', unreadCount: 1 },
  { uuid: 'pr-retry-logic', id: 'pr-retry-logic', name: 'Exponential Backoff Jitter', section: 'code-review', unreadCount: 0 },
  { uuid: 'pr-audit-logging', id: 'pr-audit-logging', name: 'Immutable Audit Trail', section: 'code-review', unreadCount: 0 },
  { uuid: 'pr-circuit-breaker', id: 'pr-circuit-breaker', name: 'Circuit Breaker Pattern', section: 'code-review', unreadCount: 1 },
  { uuid: 'pr-connection-pool', id: 'pr-connection-pool', name: 'Connection Pool Tuning', section: 'code-review', unreadCount: 0 },
  { uuid: 'pr-idempotency-keys', id: 'pr-idempotency-keys', name: 'Idempotency Key Handling', section: 'code-review', unreadCount: 2 },
  // Design Docs - architecture and design discussions
  { uuid: 'rfc-multi-region', id: 'rfc-multi-region', name: 'Multi Region Failover', section: 'design-docs', unreadCount: 0 },
  { uuid: 'rfc-cqrs', id: 'rfc-cqrs', name: 'CQRS Read Replicas', section: 'design-docs', unreadCount: 0 },
  { uuid: 'adr-service-mesh', id: 'adr-service-mesh', name: 'Service Mesh Adoption', section: 'design-docs', unreadCount: 3 },
  { uuid: 'rfc-cache-invalidation', id: 'rfc-cache-invalidation', name: 'Cache Invalidation Strategy', section: 'design-docs', unreadCount: 0 },
  // Fundamentals - SRE/Security learning channels
  { uuid: 'data-migrations', id: 'data-migrations', name: 'Data Migrations', section: 'fundamentals', unreadCount: 2 },
  { uuid: 'consensus', id: 'consensus', name: 'Consensus', section: 'fundamentals', unreadCount: 0 },
  { uuid: 'zero-trust', id: 'zero-trust', name: 'Zero Trust', section: 'fundamentals', unreadCount: 1 },
  { uuid: 'chaos-engineering', id: 'chaos-engineering', name: 'Chaos Engineering', section: 'fundamentals', unreadCount: 0 },
  { uuid: 'incident-response', id: 'incident-response', name: 'Incident Response', section: 'fundamentals', unreadCount: 0 },
  { uuid: 'distributed-tracing', id: 'distributed-tracing', name: 'Distributed Tracing', section: 'fundamentals', unreadCount: 0 },
  { uuid: 'blue-green-deploys', id: 'blue-green-deploys', name: 'Blue Green Deploys', section: 'fundamentals', unreadCount: 1 },
]

/**
 * Section configuration for the channel sidebar
 * Filters support both uuid and id for backward compatibility
 */
export const DEMO_SECTIONS = [
  {
    id: 'incidents',
    label: 'Incidents',
    filter: (c) => (c.uuid || c.id).startsWith('inc-'),
    action: {
      label: 'New',
      icon: 'plus',
      onClick: () => alert('Generate a new incident scenario based on your skill gaps'),
    },
  },
  {
    id: 'code-review',
    label: 'Code Review',
    filter: (c) => c.section === 'code-review',
    action: {
      label: 'New',
      icon: 'plus',
      onClick: () => alert('Get a PR with subtle bugs to catch'),
    },
  },
  {
    id: 'design-docs',
    label: 'Design Docs',
    filter: (c) => c.section === 'design-docs',
    action: {
      label: 'New',
      icon: 'plus',
      onClick: () => alert('Get a new architecture problem to solve'),
    },
  },
  {
    id: 'fundamentals',
    label: 'Fundamentals',
    filter: (c) => c.section === 'fundamentals',
    action: {
      label: 'New',
      icon: 'plus',
      onClick: () => alert('Explore a new concept with guided examples'),
    },
  },
]

export const DEFAULT_CHANNEL_ID = 'inc-4521-cart-500s'