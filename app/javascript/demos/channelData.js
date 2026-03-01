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
  { uuid: 'iam', id: 'iam', name: 'IAM', unreadCount: 2 },
  { uuid: 'observability', id: 'observability', name: 'Observability', unreadCount: 0 },
  { uuid: 'load-balancing', id: 'load-balancing', name: 'Load Balancing', unreadCount: 1 },
  { uuid: 'kubernetes', id: 'kubernetes', name: 'Kubernetes', unreadCount: 0 },
  { uuid: 'networking', id: 'networking', name: 'Networking', unreadCount: 3 },
  { uuid: 'databases', id: 'databases', name: 'Databases', unreadCount: 0 },
  { uuid: 'caching', id: 'caching', name: 'Caching', unreadCount: 0 },
  { uuid: 'message-queues', id: 'message-queues', name: 'Message Queues', unreadCount: 1 },
  { uuid: 'ci-cd', id: 'ci-cd', name: 'CI/CD', unreadCount: 0 },
  { uuid: 'secrets-management', id: 'secrets-management', name: 'Secrets Management', unreadCount: 2 },
  { uuid: 'tls-ssl', id: 'tls-ssl', name: 'TLS/SSL', unreadCount: 0 },
  { uuid: 'encryption', id: 'encryption', name: 'Encryption', unreadCount: 0 },
  { uuid: 'authentication', id: 'authentication', name: 'Authentication', unreadCount: 1 },
  { uuid: 'authorization', id: 'authorization', name: 'Authorization', unreadCount: 0 },
  { uuid: 'rate-limiting', id: 'rate-limiting', name: 'Rate Limiting', unreadCount: 0 },
  { uuid: 'ddos-mitigation', id: 'ddos-mitigation', name: 'DDoS Mitigation', unreadCount: 0 },
  { uuid: 'incident-response', id: 'incident-response', name: 'Incident Response', unreadCount: 2 },
  { uuid: 'disaster-recovery', id: 'disaster-recovery', name: 'Disaster Recovery', unreadCount: 0 },
  { uuid: 'backup-restore', id: 'backup-restore', name: 'Backup & Restore', unreadCount: 0 },
  { uuid: 'capacity-planning', id: 'capacity-planning', name: 'Capacity Planning', unreadCount: 1 },
  { uuid: 'auto-scaling', id: 'auto-scaling', name: 'Auto Scaling', unreadCount: 0 },
  { uuid: 'service-mesh', id: 'service-mesh', name: 'Service Mesh', unreadCount: 0 },
  { uuid: 'api-gateway', id: 'api-gateway', name: 'API Gateway', unreadCount: 0 },
  { uuid: 'container-security', id: 'container-security', name: 'Container Security', unreadCount: 1 },
  { uuid: 'supply-chain', id: 'supply-chain', name: 'Supply Chain Security', unreadCount: 0 },
  { uuid: 'logging', id: 'logging', name: 'Logging', unreadCount: 0 },
  { uuid: 'metrics', id: 'metrics', name: 'Metrics', unreadCount: 0 },
  { uuid: 'tracing', id: 'tracing', name: 'Distributed Tracing', unreadCount: 0 },
  { uuid: 'alerting', id: 'alerting', name: 'Alerting', unreadCount: 3 },
  { uuid: 'slos-slis', id: 'slos-slis', name: 'SLOs & SLIs', unreadCount: 0 },
  { uuid: 'chaos-engineering', id: 'chaos-engineering', name: 'Chaos Engineering', unreadCount: 0 },
  { uuid: 'zero-trust', id: 'zero-trust', name: 'Zero Trust', unreadCount: 1 },
  { uuid: 'network-segmentation', id: 'network-segmentation', name: 'Network Segmentation', unreadCount: 0 },
  { uuid: 'firewalls', id: 'firewalls', name: 'Firewalls', unreadCount: 0 },
  { uuid: 'vpn-tunnels', id: 'vpn-tunnels', name: 'VPN & Tunnels', unreadCount: 0 },
  { uuid: 'cdn', id: 'cdn', name: 'CDN', unreadCount: 0 },
  { uuid: 'object-storage', id: 'object-storage', name: 'Object Storage', unreadCount: 0 },
  { uuid: 'block-storage', id: 'block-storage', name: 'Block Storage', unreadCount: 0 },
  { uuid: 'file-systems', id: 'file-systems', name: 'Distributed File Systems', unreadCount: 0 },
  { uuid: 'consensus', id: 'consensus', name: 'Consensus Protocols', unreadCount: 0 },
  { uuid: 'replication', id: 'replication', name: 'Replication', unreadCount: 1 },
  { uuid: 'sharding', id: 'sharding', name: 'Sharding', unreadCount: 0 },
  { uuid: 'connection-pooling', id: 'connection-pooling', name: 'Connection Pooling', unreadCount: 0 },
  { uuid: 'circuit-breakers', id: 'circuit-breakers', name: 'Circuit Breakers', unreadCount: 0 },
  { uuid: 'retries-backoff', id: 'retries-backoff', name: 'Retries & Backoff', unreadCount: 0 },
  { uuid: 'idempotency', id: 'idempotency', name: 'Idempotency', unreadCount: 0 },
  { uuid: 'data-migrations', id: 'data-migrations', name: 'Data Migrations', unreadCount: 2 },
  { uuid: 'blue-green-deploys', id: 'blue-green-deploys', name: 'Blue-Green Deploys', unreadCount: 0 },
  { uuid: 'canary-releases', id: 'canary-releases', name: 'Canary Releases', unreadCount: 0 },
  { uuid: 'feature-flags', id: 'feature-flags', name: 'Feature Flags', unreadCount: 0 },
  { uuid: 'infrastructure-as-code', id: 'infrastructure-as-code', name: 'Infrastructure as Code', unreadCount: 1 },
  { uuid: 'config-management', id: 'config-management', name: 'Config Management', unreadCount: 0 },
  { uuid: 'audit-logging', id: 'audit-logging', name: 'Audit Logging', unreadCount: 0 },
  { uuid: 'compliance', id: 'compliance', name: 'Compliance', unreadCount: 0 },
  { uuid: 'penetration-testing', id: 'penetration-testing', name: 'Penetration Testing', unreadCount: 0 },
  { uuid: 'vulnerability-management', id: 'vulnerability-management', name: 'Vulnerability Management', unreadCount: 1 },
]

export const DEFAULT_CHANNEL_ID = 'dns'