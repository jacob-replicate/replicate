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
  { uuid: 'dns', id: 'dns', name: 'DNS', unreadCount: 0 },
  { uuid: 'consensus', id: 'consensus', name: 'Consensus', unreadCount: 0 },
  { uuid: 'replication', id: 'replication', name: 'Replication', unreadCount: 1 },
  { uuid: 'sharding', id: 'sharding', name: 'Sharding', unreadCount: 0 },
  { uuid: 'blob-storage', id: 'blob-storage', name: 'Blob Storage', unreadCount: 0 },
  { uuid: 'caching', id: 'caching', name: 'Caching', unreadCount: 0 },
  { uuid: 'queues', id: 'queues', name: 'Queues', unreadCount: 1 },
  { uuid: 'streams', id: 'streams', name: 'Streams', unreadCount: 0 },
  { uuid: 'load-balancing', id: 'load-balancing', name: 'Load Balancing', unreadCount: 0 },
  { uuid: 'service-mesh', id: 'service-mesh', name: 'Service Mesh', unreadCount: 0 },
  { uuid: 'circuit-breakers', id: 'circuit-breakers', name: 'Circuit Breakers', unreadCount: 0 },
  { uuid: 'rate-limiting', id: 'rate-limiting', name: 'Rate Limiting', unreadCount: 0 },
  { uuid: 'connection-pooling', id: 'connection-pooling', name: 'Connection Pooling', unreadCount: 2 },
  { uuid: 'retries', id: 'retries', name: 'Retries', unreadCount: 0 },
  { uuid: 'timeouts', id: 'timeouts', name: 'Timeouts', unreadCount: 0 },
  { uuid: 'idempotency', id: 'idempotency', name: 'Idempotency', unreadCount: 0 },
  { uuid: 'workload-identity', id: 'workload-identity', name: 'Workload Identity', unreadCount: 0 },
  { uuid: 'secrets', id: 'secrets', name: 'Secrets', unreadCount: 0 },
  { uuid: 'zero-trust', id: 'zero-trust', name: 'Zero Trust', unreadCount: 1 },
  { uuid: 'tls', id: 'tls', name: 'TLS', unreadCount: 0 },
  { uuid: 'mtls', id: 'mtls', name: 'mTLS', unreadCount: 0 },
  { uuid: 'oauth', id: 'oauth', name: 'OAuth', unreadCount: 0 },
  { uuid: 'rbac', id: 'rbac', name: 'RBAC', unreadCount: 0 },
  { uuid: 'observability', id: 'observability', name: 'Observability', unreadCount: 0 },
  { uuid: 'alerting', id: 'alerting', name: 'Alerting', unreadCount: 2 },
  { uuid: 'tracing', id: 'tracing', name: 'Tracing', unreadCount: 0 },
  { uuid: 'logging', id: 'logging', name: 'Logging', unreadCount: 0 },
  { uuid: 'metrics', id: 'metrics', name: 'Metrics', unreadCount: 0 },
  { uuid: 'incident-response', id: 'incident-response', name: 'Incident Response', unreadCount: 1 },
  { uuid: 'chaos', id: 'chaos', name: 'Chaos', unreadCount: 0 },
  { uuid: 'postmortems', id: 'postmortems', name: 'Postmortems', unreadCount: 0 },
  { uuid: 'deployments', id: 'deployments', name: 'Deployments', unreadCount: 0 },
  { uuid: 'rollbacks', id: 'rollbacks', name: 'Rollbacks', unreadCount: 0 },
  { uuid: 'canaries', id: 'canaries', name: 'Canaries', unreadCount: 0 },
  { uuid: 'feature-flags', id: 'feature-flags', name: 'Feature Flags', unreadCount: 0 },
  { uuid: 'migrations', id: 'migrations', name: 'Migrations', unreadCount: 1 },
  { uuid: 'backups', id: 'backups', name: 'Backups', unreadCount: 0 },
  { uuid: 'disaster-recovery', id: 'disaster-recovery', name: 'Disaster Recovery', unreadCount: 0 },
  { uuid: 'capacity', id: 'capacity', name: 'Capacity', unreadCount: 0 },
  { uuid: 'autoscaling', id: 'autoscaling', name: 'Autoscaling', unreadCount: 0 },
  { uuid: 'networking', id: 'networking', name: 'Networking', unreadCount: 0 },
  { uuid: 'cdn', id: 'cdn', name: 'CDN', unreadCount: 0 },
  { uuid: 'edge', id: 'edge', name: 'Edge', unreadCount: 0 },
  { uuid: 'kubernetes', id: 'kubernetes', name: 'Kubernetes', unreadCount: 0 },
  { uuid: 'terraform', id: 'terraform', name: 'Terraform', unreadCount: 0 },
  { uuid: 'gitops', id: 'gitops', name: 'GitOps', unreadCount: 0 },
  { uuid: 'api-design', id: 'api-design', name: 'API Design', unreadCount: 0 },
  { uuid: 'grpc', id: 'grpc', name: 'gRPC', unreadCount: 0 },
  { uuid: 'graphql', id: 'graphql', name: 'GraphQL', unreadCount: 0 },
  { uuid: 'webhooks', id: 'webhooks', name: 'Webhooks', unreadCount: 0 },
]

export const DEFAULT_CHANNEL_ID = 'dns'