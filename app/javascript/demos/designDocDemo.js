/**
 * Design Doc Demo - Architecture visualization and grading exercise
 *
 * Flow:
 * 1. Jacob poses a hard architecture problem
 * 2. 30-second countdown for user to visualize their solution
 * 3. Another engineer shares their first draft
 * 4. User grades the draft with multiple choice
 */

export const AUTH_SERVICE_REDESIGN_MESSAGES = [
  {
    id: 'design-prompt',
    sequence: 0,
    author: { name: 'Jacob Comer', avatar: '/jacob-square.jpg' },
    components: [
      {
        type: 'text',
        content: '**Auth Service Redesign**\n\nOur current auth service is a monolith handling 50k req/s. We\'re seeing p99 latency spikes during token refresh storms (Monday 9am, session expiry waves).\n\nConstraints:\n• Can\'t break existing API contracts\n• Must support graceful degradation\n• Zero-downtime migration required\n• Budget for 2 engineers, 6 weeks',
      },
      {
        type: 'text',
        content: '**Your task:** Visualize how you\'d decompose this. What services? What data flows? Where are the failure domains?',
      },
      {
        type: 'countdown',
        duration: 30,
        label: 'Think through your approach',
      },
    ],
  },
  {
    id: 'engineer-draft',
    sequence: 1,
    delay: 32000,
    author: { name: 'maya', avatar: '/profile-photo-3.jpg' },
    components: [
      {
        type: 'text',
        content: 'Here\'s my first draft for the auth service redesign:',
      },
      {
        type: 'text',
        content: '**Proposed Architecture:**\n\n1. Split into 3 services:\n   • `auth-gateway` - handles all incoming auth requests, rate limiting\n   • `token-service` - JWT generation/validation, refresh logic\n   • `session-store` - Redis cluster for active sessions\n\n2. Add a token refresh queue (SQS) to smooth out Monday morning storms\n\n3. Implement stale-while-revalidate for tokens - return cached token while refreshing in background\n\n4. Migration: run both systems in parallel, shadow traffic for 2 weeks, then gradual cutover with feature flags',
      },
      {
        type: 'code',
        language: 'yaml',
        content: `# Simplified data flow
Client -> auth-gateway -> token-service -> session-store
                      \\-> refresh-queue -> token-service (async)

# Failure domains
- auth-gateway down: return cached decisions (graceful degradation)
- token-service down: extend existing tokens, queue refreshes
- session-store down: fallback to stateless JWT validation`,
      },
    ],
  },
  {
    id: 'grade-prompt',
    sequence: 2,
    delay: 34000,
    isSystem: true,
    components: [
      {
        type: 'multiple_choice',
        prompt: 'How would you grade Maya\'s first draft?',
        options: [
          { id: 'a', text: 'Strong foundation - addresses core issues, ready for detailed design' },
          { id: 'b', text: 'Good start - missing some failure modes, needs iteration' },
          { id: 'c', text: 'Needs work - over-engineered for the constraints given' },
          { id: 'd', text: 'Off track - doesn\'t address the actual bottleneck' },
        ],
      },
    ],
  },
]

export const EVENT_SOURCING_MESSAGES = [
  {
    id: 'design-prompt',
    sequence: 0,
    author: { name: 'Jacob Comer', avatar: '/jacob-square.jpg' },
    components: [
      {
        type: 'text',
        content: '**Event Sourcing for Order Service**\n\nWe\'re rebuilding the order service. Current state: PostgreSQL with 500M rows, 10k writes/sec, frequent audit requests ("show me every change to order #12345").\n\nThe team is debating event sourcing vs traditional CRUD.\n\nConstraints:\n• Must replay any order\'s history in <100ms\n• Auditors need immutable records\n• Can\'t increase infrastructure cost >20%\n• Team has no event sourcing experience',
      },
      {
        type: 'text',
        content: '**Your task:** Should we use event sourcing here? What are the tradeoffs? How would you structure the event store?',
      },
      {
        type: 'countdown',
        duration: 30,
        label: 'Consider the tradeoffs',
      },
    ],
  },
  {
    id: 'engineer-draft',
    sequence: 1,
    delay: 32000,
    author: { name: 'daniel', avatar: '/profile-photo-2.jpg' },
    components: [
      {
        type: 'text',
        content: 'My take on event sourcing for orders:',
      },
      {
        type: 'text',
        content: '**Recommendation: Hybrid approach**\n\n1. Keep PostgreSQL as primary for reads (materialized views)\n2. Add event log table for writes - append-only, immutable\n3. Use CDC (Change Data Capture) to sync events to audit system\n\n**Why not full event sourcing:**\n• Team learning curve is real risk for 6-week timeline\n• 10k writes/sec is achievable with PostgreSQL + good indexing\n• Event replay <100ms is hard with 500M rows unless you pre-compute snapshots\n\n**Event structure:**',
      },
      {
        type: 'code',
        language: 'sql',
        content: `CREATE TABLE order_events (
  id BIGSERIAL PRIMARY KEY,
  order_id UUID NOT NULL,
  event_type VARCHAR(50) NOT NULL,
  payload JSONB NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  actor_id UUID,
  -- Never update, never delete
  CONSTRAINT immutable CHECK (TRUE)
);

-- Snapshot every 100 events for fast replay
CREATE TABLE order_snapshots (
  order_id UUID PRIMARY KEY,
  snapshot JSONB NOT NULL,
  event_sequence BIGINT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);`,
      },
    ],
  },
  {
    id: 'grade-prompt',
    sequence: 2,
    delay: 34000,
    isSystem: true,
    components: [
      {
        type: 'multiple_choice',
        prompt: 'How would you grade Daniel\'s approach?',
        options: [
          { id: 'a', text: 'Excellent - pragmatic hybrid that meets constraints without over-engineering' },
          { id: 'b', text: 'Good - but snapshots add complexity, simpler approach possible' },
          { id: 'c', text: 'Risky - CDC introduces eventual consistency problems' },
          { id: 'd', text: 'Wrong direction - full event sourcing is worth the learning curve here' },
        ],
      },
    ],
  },
]

export const MULTI_REGION_FAILOVER_MESSAGES = [
  {
    id: 'design-prompt',
    sequence: 0,
    author: { name: 'Jacob Comer', avatar: '/jacob-square.jpg' },
    components: [
      {
        type: 'text',
        content: '**Multi-Region Failover**\n\nWe\'re expanding to EU and need multi-region for compliance (GDPR data residency) and reliability.\n\nCurrent state: Single US-East region, PostgreSQL primary + 2 replicas, ~200ms acceptable latency for EU users today.\n\nConstraints:\n• EU data must stay in EU (legal requirement)\n• RPO: 1 minute, RTO: 5 minutes\n• Budget: Can\'t double infrastructure cost\n• Some data is global (product catalog), some is regional (user PII)',
      },
      {
        type: 'text',
        content: '**Your task:** How do you partition data between regions? What\'s your failover strategy? Where does consensus happen?',
      },
      {
        type: 'countdown',
        duration: 30,
        label: 'Design your multi-region strategy',
      },
    ],
  },
  {
    id: 'engineer-draft',
    sequence: 1,
    delay: 32000,
    author: { name: 'alex', avatar: '/profile-photo-1.jpg' },
    components: [
      {
        type: 'text',
        content: 'Here\'s my multi-region proposal:',
      },
      {
        type: 'text',
        content: '**Data Partitioning Strategy:**\n\n1. **Global data** (product catalog, configs): Single source in US, async replicate to EU read replicas. Accept 30s staleness.\n\n2. **Regional PII** (users, orders): Each region owns its data. EU users → EU database, US users → US database. No cross-region replication of PII.\n\n3. **Session data**: Regional Redis clusters, no replication. User re-auths if they switch regions (rare).\n\n**Failover:**\n• Region health checks every 10s\n• DNS failover with 60s TTL\n• For regional data: accept that EU users can\'t access service if EU is down (compliance > availability)\n• For global data: promote EU replica to primary, accept writes in EU temporarily',
      },
      {
        type: 'code',
        language: 'text',
        content: `┌─────────────┐         ┌─────────────┐
│   US-East   │         │   EU-West   │
├─────────────┤         ├─────────────┤
│ Global DB   │───────▶ │ Global      │
│ (primary)   │  async  │ (replica)   │
├─────────────┤         ├─────────────┤
│ US Users DB │         │ EU Users DB │
│ (isolated)  │    ✗    │ (isolated)  │
└─────────────┘         └─────────────┘

Routing: GeoDNS + user_region claim in JWT`,
      },
    ],
  },
  {
    id: 'grade-prompt',
    sequence: 2,
    delay: 34000,
    isSystem: true,
    components: [
      {
        type: 'multiple_choice',
        prompt: 'How would you grade Alex\'s multi-region design?',
        options: [
          { id: 'a', text: 'Solid - clean separation, compliance-first, realistic tradeoffs' },
          { id: 'b', text: 'Good foundation - but 60s DNS TTL won\'t meet 5min RTO reliably' },
          { id: 'c', text: 'Overcomplicated - could use a simpler active-passive setup' },
          { id: 'd', text: 'Flawed - global data failover strategy creates split-brain risk' },
        ],
      },
    ],
  },
]

// Export registry of design doc demos
export const DESIGN_DOC_DEMOS = {
  'rfc-auth-service': AUTH_SERVICE_REDESIGN_MESSAGES,
  'adr-event-sourcing': EVENT_SOURCING_MESSAGES,
  'rfc-multi-region': MULTI_REGION_FAILOVER_MESSAGES,
}