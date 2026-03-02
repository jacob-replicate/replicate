/**
 * DNS/DB Locks Incident Demo Data
 */

// Generate dynamic timestamps starting 15 minutes ago
const generateTimestamps = () => {
  const now = new Date()
  const startTime = new Date(now.getTime() - 15 * 60 * 1000) // 15 minutes ago

  // Message timestamps as offsets from start (in seconds)
  // Total span is ~15 minutes, ending near "now"
  const offsets = [
    0,      // msg_1: PagerDuty alert
    60,     // msg_2: Maya takes IC
    90,     // msg_3: Daniel on it (thread)
    120,    // msg_4: Alex offers help (thread)
    150,    // msg_5: Maya assigns alex (thread)
    240,    // msg_6: Daniel finds issue
    270,    // msg_7: Daniel shows diff
    300,    // msg_8: Thread - Maya asks about other services
    330,    // msg_9: Thread - Alex confirms isolated
    360,    // msg_10: Thread - Maya focuses
    420,    // msg_11: Daniel confirms deadlock
    480,    // msg_12: First narrator question
    540,    // msg_13: Daniel and Maya discuss
    570,    // msg_14: Thread - risk question
    600,    // msg_15: Thread - Maya quantifies
    630,    // msg_16: Thread - alex rollback
    720,    // msg_17: Preparing revert
    780,    // msg_18: Revert deployed
    840,    // msg_19: Second narrator question
    900,    // msg_20: Maya wraps up
    930,    // msg_21: Alex confirms
    960,    // msg_22: Thread - postmortem
    990,    // msg_23: Final narrator question
  ]

  return offsets.map(offset => {
    const time = new Date(startTime.getTime() + offset * 1000)
    return time.toISOString()
  })
}


// Generate timestamps dynamically
const timestamps = generateTimestamps()

const INCIDENT_MESSAGES = [
  // Message 1: Maya shares the alert
  {
    id: 'msg_1',
    sequence: 1,
    author: { name: 'maya', avatar: '/profile-photo-3.jpg', status: { emoji: '🌴', text: 'OOO - back Monday' } },
    created_at: timestamps[0],
    components: [
      {
        type: 'text',
        content: 'just got paged — connection pool is spiking',
      },
      {
        type: 'monitor',
        title: 'PostgreSQL Connection Pool',
        metric: 'orders-db-primary',
        value: 98,
        zoneBreaks: [0, 0.6, 0.85, 1.05],
        dataPoints: [8, 9, 11, 10, 12, 14, 13, 15, 18, 17, 21, 24, 26, 29, 33, 38, 42, 48, 53, 61, 68, 74, 79, 83, 88, 91, 94, 96, 97, 98],
      },
    ],
    reactions: [
      { emoji: '🔥', count: 4 },
      { emoji: '👀', count: 7 }
    ]
  },
  // Message 2: Maya takes IC
  {
    id: 'msg_2',
    sequence: 2,
    author: { name: 'maya', avatar: '/profile-photo-3.jpg' },
    created_at: timestamps[1],
    components: [
      {
        type: 'text',
        content: 'taking IC. @daniel can you pull up the connection metrics? seeing `max_connections=50` but we should have headroom',
      },
    ]
  },
  // Message 3: Thread reply - daniel on it
  {
    id: 'msg_3',
    sequence: 3,
    parent_message_id: 'msg_2',
    author: { name: 'daniel', avatar: '/profile-photo-2.jpg', status: { emoji: '📅', text: 'In a meeting' } },
    created_at: timestamps[2],
    components: [
      { type: 'text', content: 'on it — pulling grafana now' }
    ],
  },
  // Message 4: Thread reply - alex offers help
  {
    id: 'msg_4',
    sequence: 4,
    parent_message_id: 'msg_2',
    author: { name: 'alex', avatar: '/profile-photo-1.jpg', status: { emoji: '💻', text: 'Focusing' } },
    created_at: timestamps[3],
    components: [
      { type: 'text', content: 'anything I can help with?' }
    ],
  },
  // Message 5: Thread reply - maya assigns alex
  {
    id: 'msg_5',
    sequence: 5,
    parent_message_id: 'msg_2',
    author: { name: 'maya', avatar: '/profile-photo-3.jpg' },
    created_at: timestamps[4],
    components: [
      { type: 'text', content: 'alex check if this is isolated to orders or if payments is affected too' }
    ],
  },
  // Message 6: Daniel finds the issue with code block
  {
    id: 'msg_6',
    sequence: 6,
    author: { name: 'daniel', avatar: '/profile-photo-2.jpg' },
    created_at: timestamps[5],
    components: [
      {
        type: 'text',
        content: 'found it — connection acquire time spiking. looks like queries are hanging and never returning connections to the pool',
      },
      {
        type: 'code',
        language: 'sql',
        content: `-- active connections by state
SELECT state, count(*), max(now() - query_start) as max_duration
FROM pg_stat_activity WHERE datname = 'orders'
GROUP BY state;

 state  | count |  max_duration
--------+-------+----------------
 active |    47 | 00:04:23.445   -- these should be milliseconds
 idle   |     3 | 00:00:01.234`,
      }
    ],
    reactions: [
      { emoji: '😱', count: 3 },
    ],
  },
  // Message 7: Alex finds the problematic diff
  {
    id: 'msg_7',
    sequence: 7,
    author: { name: 'alex', avatar: '/profile-photo-1.jpg' },
    created_at: timestamps[6],
    components: [
      {
        type: 'text',
        content: 'payments is fine, but I found something weird — someone added a new SELECT FOR UPDATE yesterday that\'s taking row locks',
      },
      {
        type: 'diff',
        filename: 'internal/orders/repository.go',
        lines: [
          { type: 'context', text: 'func (r *Repository) GetOrderForProcessing(ctx context.Context, id string) (*Order, error) {' },
          { type: 'remove', text: '    return r.db.GetOrder(ctx, id)' },
          { type: 'add', text: '    // Lock row to prevent double-processing' },
          { type: 'add', text: '    return r.db.QueryRow(ctx, `SELECT * FROM orders WHERE id = $1 FOR UPDATE`, id)' },
          { type: 'context', text: '}' },
        ],
      }
    ],
  },
  // Message 8: Thread reply - daniel explains
  {
    id: 'msg_8',
    sequence: 8,
    parent_message_id: 'msg_7',
    author: { name: 'daniel', avatar: '/profile-photo-2.jpg' },
    created_at: timestamps[7],
    components: [
      { type: 'text', content: 'oh no... FOR UPDATE with no timeout will wait forever for the lock' }
    ],
  },
  // Message 9: Thread reply - alex connects the dots
  {
    id: 'msg_9',
    sequence: 9,
    parent_message_id: 'msg_7',
    author: { name: 'alex', avatar: '/profile-photo-1.jpg' },
    created_at: timestamps[8],
    components: [
      { type: 'text', content: 'and if multiple workers try to process the same order...' }
    ],
  },
  // Message 10: Thread reply - daniel names it
  {
    id: 'msg_10',
    sequence: 10,
    parent_message_id: 'msg_7',
    author: { name: 'daniel', avatar: '/profile-photo-2.jpg' },
    created_at: timestamps[9],
    components: [
      { type: 'text', content: 'deadlock city 💀' }
    ],
  },
  // Message 11: Maya confirms with another code block + monitor
  {
    id: 'msg_11',
    sequence: 11,
    author: { name: 'maya', avatar: '/profile-photo-3.jpg' },
    created_at: timestamps[10],
    components: [
      {
        type: 'text',
        content: 'confirmed — we have 23 transactions waiting on each other. classic deadlock pattern',
      },
      {
        type: 'code',
        language: 'sql',
        content: `-- blocked queries waiting on locks
SELECT blocked.pid, blocked.query, blocking.pid as blocking_pid
FROM pg_stat_activity blocked
JOIN pg_locks bl ON bl.pid = blocked.pid
JOIN pg_locks l ON l.relation = bl.relation AND l.pid != bl.pid
JOIN pg_stat_activity blocking ON l.pid = blocking.pid
WHERE NOT bl.granted;`,
      },
    ],
  },
  // Message 13: Daniel proposes options
  {
    id: 'msg_13',
    sequence: 13,
    author: { name: 'daniel', avatar: '/profile-photo-2.jpg' },
    created_at: timestamps[12],
    components: [
      {
        type: 'text',
        content: 'options: (1) kill the stuck queries and rollback, (2) add NOWAIT or SKIP LOCKED to the query, (3) revert the commit entirely',
      },
      {
        type: 'text',
        content: "I'd vote revert — the FOR UPDATE approach needs a proper queue, not row locking",
      }
    ],
    reactions: [
      { emoji: '👍', count: 2 },
      { emoji: '💯', count: 1 },
    ],
  },
  // Message 14: Thread reply - alex volunteers
  {
    id: 'msg_14',
    sequence: 14,
    parent_message_id: 'msg_13',
    author: { name: 'alex', avatar: '/profile-photo-1.jpg' },
    created_at: timestamps[13],
    components: [
      { type: 'text', content: 'agreed — I can have the revert ready in 2 min' }
    ],
  },
  // Message 15: Thread reply - maya delegates
  {
    id: 'msg_15',
    sequence: 15,
    parent_message_id: 'msg_13',
    author: { name: 'maya', avatar: '/profile-photo-3.jpg' },
    created_at: timestamps[14],
    components: [
      { type: 'text', content: 'do it. daniel can you kill the stuck connections so we recover faster?' }
    ],
  },
  // Message 16: Thread reply - daniel confirms
  {
    id: 'msg_16',
    sequence: 16,
    parent_message_id: 'msg_13',
    author: { name: 'daniel', avatar: '/profile-photo-2.jpg' },
    created_at: timestamps[15],
    components: [
      { type: 'text', content: 'already on it' }
    ],
  },
  // Message 17: Daniel kills connections
  {
    id: 'msg_17',
    sequence: 17,
    author: { name: 'daniel', avatar: '/profile-photo-2.jpg' },
    created_at: timestamps[16],
    components: [
      {
        type: 'text',
        content: 'killed 23 stuck connections. pool is recovering',
      },
      {
        type: 'code',
        language: 'sql',
        content: `SELECT pg_terminate_backend(pid) 
FROM pg_stat_activity 
WHERE state = 'active' 
  AND query_start < now() - interval '1 minute'
  AND datname = 'orders';

-- 23 connections terminated`,
      }
    ],
  },
  // Message 18: Maya confirms resolution (edited)
  {
    id: 'msg_18',
    sequence: 18,
    author: { name: 'maya', avatar: '/profile-photo-3.jpg' },
    created_at: timestamps[17],
    updated_at: timestamps[18],
    components: [
      {
        type: 'text',
        content: 'revert is deployed, pool is back to normal — down to 12 active connections now. @oncall marking resolved but we need a proper fix for the double-processing issue',
      }
    ],
    reactions: [
      { emoji: '🎉', count: 4 },
      { emoji: '🙏', count: 2 },
    ],
  },
  // Message 20: Maya wraps up
  {
    id: 'msg_20',
    sequence: 20,
    author: { name: 'maya', avatar: '/profile-photo-3.jpg' },
    created_at: timestamps[19],
    components: [
      {
        type: 'text',
        content: "created JIRA-4521 for the proper fix. @alex can you add a Datadog monitor for duplicate order IDs in the meantime?",
      }
    ],
  },
  // Message 21: Alex confirms
  {
    id: 'msg_21',
    sequence: 21,
    author: { name: 'alex', avatar: '/profile-photo-1.jpg' },
    created_at: timestamps[20],
    components: [
      {
        type: 'text',
        content: 'on it. will alert if we see any order_id processed more than once in a 5 min window',
      }
    ],
    reactions: [
      { emoji: '👍', count: 2 },
    ],
  },
  // Message 22: Daniel shares postmortem thought
  {
    id: 'msg_22',
    sequence: 22,
    author: { name: 'daniel', avatar: '/profile-photo-2.jpg' },
    created_at: timestamps[21],
    components: [
      {
        type: 'text',
        content: "for the postmortem — the real issue is we're using database locks for job coordination. should've been a proper queue from day one",
      }
    ],
  },
  // Message 23: Final question from narrator
  {
    id: 'msg_23',
    sequence: 23,
    isSystem: true,
    created_at: timestamps[22],
    components: [
      {
        type: 'multiple_choice',
        options: [
          {
            id: 'a',
            thought: 'Keep using row locks, but switch to SKIP LOCKED',
            message: 'for the follow-up ticket — we could use SKIP LOCKED instead of FOR UPDATE. that way workers skip rows that are already being processed instead of blocking'
          },
          {
            id: 'b',
            thought: 'Introduce a distributed lock service (Redis/Zookeeper)',
            message: 'thinking we need a distributed lock here — Redis or ZK. database row locks aren\'t meant for this kind of coordination'
          },
          {
            id: 'c',
            thought: 'Move job coordination into a proper queue with delivery guarantees',
            message: 'this needs a proper job queue with exactly-once semantics. SQS FIFO or something similar — row locking for job coordination is always going to be fragile'
          },
        ],
      }
    ],
  },
]

/**
 * Authentication Outage Demo Data
 * JWT signing key rotation gone wrong
 */
const AUTH_INCIDENT_MESSAGES = [
  {
    id: 'auth_1',
    sequence: 1,
    author: { name: 'alex', avatar: '/profile-photo-1.jpg', status: { emoji: '💻', text: 'Focusing' } },
    created_at: new Date(Date.now() - 12 * 60 * 1000).toISOString(),
    components: [
      {
        type: 'text',
        content: 'getting reports of users being logged out across all services. support queue is blowing up',
      },
    ],
    reactions: [
      { emoji: '😬', count: 5 },
    ]
  },
  {
    id: 'auth_2',
    sequence: 2,
    author: { name: 'maya', avatar: '/profile-photo-3.jpg' },
    created_at: new Date(Date.now() - 11 * 60 * 1000).toISOString(),
    components: [
      {
        type: 'text',
        content: 'I\'ll take IC. seeing 401s spike in the API gateway — this started about 10 min ago',
      },
      {
        type: 'monitor',
        title: 'API Gateway 401 Responses',
        metric: 'auth-gateway',
        value: 34,
        unit: '%',
        zoneBreaks: [0, 0.05, 0.15, 0.30],
        dataPoints: [1, 1, 1, 2, 1, 2, 1, 2, 3, 4, 6, 9, 13, 17, 21, 25, 28, 30, 32, 34],
      },
    ],
  },
  {
    id: 'auth_3',
    sequence: 3,
    parent_message_id: 'auth_2',
    author: { name: 'daniel', avatar: '/profile-photo-2.jpg' },
    created_at: new Date(Date.now() - 10.5 * 60 * 1000).toISOString(),
    components: [
      { type: 'text', content: 'checking the auth service logs now' }
    ],
  },
  {
    id: 'auth_4',
    sequence: 4,
    author: { name: 'daniel', avatar: '/profile-photo-2.jpg' },
    created_at: new Date(Date.now() - 9 * 60 * 1000).toISOString(),
    components: [
      {
        type: 'text',
        content: 'found it — JWT validation is failing. the signing key doesn\'t match',
      },
      {
        type: 'code',
        language: 'text',
        content: `level=error msg="token validation failed" error="signature is invalid"
level=error msg="token validation failed" error="signature is invalid"
level=error msg="token validation failed" error="signature is invalid"
[... 847 more in last 5 minutes]`,
      }
    ],
  },
  {
    id: 'auth_5',
    sequence: 5,
    parent_message_id: 'auth_4',
    author: { name: 'alex', avatar: '/profile-photo-1.jpg' },
    created_at: new Date(Date.now() - 8.5 * 60 * 1000).toISOString(),
    components: [
      { type: 'text', content: 'wait, didn\'t we rotate the JWT keys this morning?' }
    ],
  },
  {
    id: 'auth_6',
    sequence: 6,
    parent_message_id: 'auth_4',
    author: { name: 'maya', avatar: '/profile-photo-3.jpg' },
    created_at: new Date(Date.now() - 8 * 60 * 1000).toISOString(),
    components: [
      { type: 'text', content: 'yes — scheduled rotation at 6am. but we should have both keys active during the transition window' }
    ],
  },
  {
    id: 'auth_7',
    sequence: 7,
    author: { name: 'alex', avatar: '/profile-photo-1.jpg' },
    created_at: new Date(Date.now() - 7 * 60 * 1000).toISOString(),
    components: [
      {
        type: 'text',
        content: 'found the problem — the key rotation script removed the old key immediately instead of keeping both active',
      },
      {
        type: 'diff',
        filename: 'scripts/rotate-jwt-keys.sh',
        lines: [
          { type: 'context', text: '# Rotate JWT signing keys' },
          { type: 'context', text: 'vault write auth/jwt/config key="$NEW_KEY"' },
          { type: 'remove', text: '# Keep old key active for 24h transition' },
          { type: 'remove', text: '# vault write auth/jwt/config old_key="$OLD_KEY" old_key_ttl=24h' },
          { type: 'add', text: '# Clean rotation - remove old key' },
          { type: 'add', text: 'vault delete auth/jwt/old_key' },
        ],
      }
    ],
    reactions: [
      { emoji: '🤦', count: 4 },
    ],
  },
  {
    id: 'auth_8',
    sequence: 8,
    parent_message_id: 'auth_7',
    author: { name: 'daniel', avatar: '/profile-photo-2.jpg' },
    created_at: new Date(Date.now() - 6.5 * 60 * 1000).toISOString(),
    components: [
      { type: 'text', content: 'so every token issued before 6am is now invalid 😬' }
    ],
  },
  {
    id: 'auth_9',
    sequence: 9,
    author: { name: 'maya', avatar: '/profile-photo-3.jpg' },
    created_at: new Date(Date.now() - 5 * 60 * 1000).toISOString(),
    components: [
      {
        type: 'text',
        content: 'we need to restore the old key ASAP. @daniel can you pull it from vault audit logs? it should still be in the backup',
      },
    ],
  },
  {
    id: 'auth_10',
    sequence: 10,
    author: { name: 'daniel', avatar: '/profile-photo-2.jpg' },
    created_at: new Date(Date.now() - 3 * 60 * 1000).toISOString(),
    components: [
      {
        type: 'text',
        content: 'got it from the hourly backup. restoring old key alongside the new one now',
      },
      {
        type: 'code',
        language: 'bash',
        content: `$ vault write auth/jwt/config \\
    key="$NEW_KEY" \\
    old_key="$RESTORED_KEY" \\
    old_key_ttl="23h"

Success! Both keys now active.`,
      }
    ],
    reactions: [
      { emoji: '🎉', count: 3 },
    ],
  },
  {
    id: 'auth_11',
    sequence: 11,
    author: { name: 'alex', avatar: '/profile-photo-1.jpg' },
    created_at: new Date(Date.now() - 2 * 60 * 1000).toISOString(),
    components: [
      {
        type: 'text',
        content: '401 rate dropping — down to 2% and falling. users should be able to refresh and get back in',
      },
    ],
  },
  {
    id: 'auth_12',
    sequence: 12,
    author: { name: 'maya', avatar: '/profile-photo-3.jpg' },
    created_at: new Date(Date.now() - 1 * 60 * 1000).toISOString(),
    components: [
      {
        type: 'text',
        content: 'good catch everyone. closing this out — @alex can you file the postmortem? we need to fix that rotation script and add a test that validates both keys stay active during transition',
      },
    ],
    reactions: [
      { emoji: '👍', count: 2 },
    ],
  },
]

/**
 * Partitioning Cold Case Demo
 *
 * A "resolved" incident from 3 days ago where the team thought they fixed
 * a hot partition issue by adding more shards. But the real flaw remains:
 * their partition key choice (user_id) doesn't account for power users.
 */
const PARTITIONING_INCIDENT_MESSAGES = [
  {
    id: 'part_1',
    sequence: 1,
    author: { name: 'alex', avatar: '/profile-photo-1.jpg' },
    created_at: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000 - 45 * 60 * 1000).toISOString(), // 3 days + 45 min ago
    components: [
      {
        type: 'text',
        content: 'events service latency spiking hard — p99 is through the roof',
      },
      {
        type: 'monitor',
        title: 'Events Service p99 Latency',
        metric: 'events-api-latency',
        value: 2847,
        unit: 'ms',
        zoneBreaks: [0, 0.2, 0.5, 0.8],
        dataPoints: [45, 48, 52, 55, 61, 89, 134, 198, 287, 445, 612, 834, 1102, 1456, 1823, 2103, 2412, 2634, 2756, 2847],
      },
    ],
    reactions: [
      { emoji: '🔥', count: 5 },
    ]
  },
  {
    id: 'part_2',
    sequence: 2,
    author: { name: 'maya', avatar: '/profile-photo-3.jpg' },
    created_at: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000 - 42 * 60 * 1000).toISOString(),
    components: [
      {
        type: 'text',
        content: 'taking IC. @daniel what does the partition distribution look like? I\'m seeing uneven load on the Kafka dashboard',
      },
    ],
  },
  {
    id: 'part_3',
    sequence: 3,
    author: { name: 'daniel', avatar: '/profile-photo-2.jpg' },
    created_at: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000 - 38 * 60 * 1000).toISOString(),
    components: [
      {
        type: 'text',
        content: 'yep, we have a hot partition. partition 7 is getting hammered while the others are basically idle',
      },
      {
        type: 'code',
        language: 'text',
        content: `Partition | Events/sec | Lag    | Consumer
----------|------------|--------|----------
    0     |     124    |    2   | consumer-1
    1     |      98    |    0   | consumer-2
    2     |     156    |    4   | consumer-3
    3     |     112    |    1   | consumer-4
    4     |     134    |    3   | consumer-5
    5     |      89    |    0   | consumer-6
    6     |     145    |    2   | consumer-7
    7     |  12,847    | 34,291 | consumer-8  ← hot partition
    8     |     167    |    5   | consumer-9
    9     |     103    |    1   | consumer-10`,
      }
    ],
  },
  {
    id: 'part_4',
    sequence: 4,
    parent_message_id: 'part_3',
    author: { name: 'alex', avatar: '/profile-photo-1.jpg' },
    created_at: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000 - 36 * 60 * 1000).toISOString(),
    components: [
      { type: 'text', content: 'whoa, partition 7 has 100x the traffic. what\'s the partition key?' }
    ],
  },
  {
    id: 'part_5',
    sequence: 5,
    parent_message_id: 'part_3',
    author: { name: 'daniel', avatar: '/profile-photo-2.jpg' },
    created_at: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000 - 35 * 60 * 1000).toISOString(),
    components: [
      { type: 'text', content: 'user_id — we partition by user to keep all events for a user on the same consumer for ordering' }
    ],
  },
  {
    id: 'part_6',
    sequence: 6,
    author: { name: 'alex', avatar: '/profile-photo-1.jpg' },
    created_at: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000 - 32 * 60 * 1000).toISOString(),
    components: [
      {
        type: 'text',
        content: 'found it — Acme Corp\'s integration went live yesterday. they\'re pushing 12k events/sec through user_id `acme_service_account`',
      },
      {
        type: 'code',
        language: 'sql',
        content: `SELECT user_id, count(*) as events_last_hour
FROM events 
WHERE created_at > now() - interval '1 hour'
GROUP BY user_id
ORDER BY events_last_hour DESC
LIMIT 5;

     user_id          | events_last_hour
----------------------+------------------
 acme_service_account |       46,123,847
 user_8847123         |           12,445
 user_2234891         |            8,234
 user_9912834         |            6,122
 user_4456721         |            5,891`,
      }
    ],
    reactions: [
      { emoji: '💀', count: 3 },
    ],
  },
  {
    id: 'part_7',
    sequence: 7,
    parent_message_id: 'part_6',
    author: { name: 'maya', avatar: '/profile-photo-3.jpg' },
    created_at: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000 - 30 * 60 * 1000).toISOString(),
    components: [
      { type: 'text', content: 'one user is 99.9% of traffic on that partition. classic hot key problem' }
    ],
  },
  {
    id: 'part_8',
    sequence: 8,
    author: { name: 'daniel', avatar: '/profile-photo-2.jpg' },
    created_at: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000 - 27 * 60 * 1000).toISOString(),
    components: [
      {
        type: 'text',
        content: 'we only have 10 partitions — let me bump it to 100. that should spread the load better, and I\'ll add more consumers to match',
      },
    ],
  },
  {
    id: 'part_9',
    sequence: 9,
    parent_message_id: 'part_8',
    author: { name: 'alex', avatar: '/profile-photo-1.jpg' },
    created_at: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000 - 25 * 60 * 1000).toISOString(),
    components: [
      { type: 'text', content: 'will that actually help? same user_id will still hash to one partition' }
    ],
  },
  {
    id: 'part_10',
    sequence: 10,
    parent_message_id: 'part_8',
    author: { name: 'daniel', avatar: '/profile-photo-2.jpg' },
    created_at: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000 - 24 * 60 * 1000).toISOString(),
    components: [
      { type: 'text', content: 'true but with more partitions we get better overall distribution — reduces the probability any single partition becomes a bottleneck' }
    ],
  },
  {
    id: 'part_11',
    sequence: 11,
    author: { name: 'maya', avatar: '/profile-photo-3.jpg' },
    created_at: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000 - 20 * 60 * 1000).toISOString(),
    components: [
      {
        type: 'text',
        content: 'let\'s do it. @daniel go ahead with the partition expansion. I\'ll coordinate with Acme to see if they can rate limit on their end while we scale up',
      },
    ],
  },
  {
    id: 'part_12',
    sequence: 12,
    author: { name: 'daniel', avatar: '/profile-photo-2.jpg' },
    created_at: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000 - 12 * 60 * 1000).toISOString(),
    components: [
      {
        type: 'text',
        content: 'partition expansion complete — 100 partitions now, spun up 50 more consumers. lag is clearing',
      },
      {
        type: 'code',
        language: 'bash',
        content: `$ kafka-reassign-partitions.sh --execute \\
    --reassignment-json-file expand-to-100.json

Partition reassignment completed successfully.

$ kubectl scale deployment events-consumer --replicas=50
deployment.apps/events-consumer scaled`,
      }
    ],
    reactions: [
      { emoji: '🚀', count: 2 },
    ],
  },
  {
    id: 'part_13',
    sequence: 13,
    author: { name: 'alex', avatar: '/profile-photo-1.jpg' },
    created_at: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000 - 8 * 60 * 1000).toISOString(),
    components: [
      {
        type: 'text',
        content: 'latency recovering — p99 down to 180ms and dropping. Acme also said they can batch their events instead of sending individually which should help',
      },
    ],
  },
  {
    id: 'part_14',
    sequence: 14,
    author: { name: 'maya', avatar: '/profile-photo-3.jpg' },
    created_at: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000 - 5 * 60 * 1000).toISOString(),
    components: [
      {
        type: 'text',
        content: 'perfect, marking this resolved. good work everyone 🎉',
      },
    ],
    reactions: [
      { emoji: '🎉', count: 4 },
      { emoji: '💪', count: 2 },
    ],
  },
  {
    id: 'part_15',
    sequence: 15,
    author: { name: 'daniel', avatar: '/profile-photo-2.jpg' },
    created_at: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000 - 3 * 60 * 1000).toISOString(),
    components: [
      {
        type: 'text',
        content: 'filed the postmortem. root cause was insufficient partitions for the scale of our enterprise customers. we\'re in a better spot now with 100 partitions and autoscaling consumers',
      },
    ],
    reactions: [
      { emoji: '👍', count: 3 },
    ],
  },
  // System message: the "cold case" question
  // The team thinks they fixed it by adding partitions, but the real issue is the partition key choice
  {
    id: 'part_16',
    sequence: 16,
    isSystem: true,
    created_at: new Date().toISOString(),
    components: [
      {
        type: 'multiple_choice',
        options: [
          {
            id: 'a',
            thought: 'we never modeled asymmetric user growth. partitions don\'t fix hot accounts',
            message: 'we never modeled asymmetric user growth. partitions don\'t fix hot accounts'
          },
          {
            id: 'b',
            thought: 'there\'s no backpressure. we find out a partition is overloaded after it\'s too late',
            message: 'there\'s no backpressure. we find out a partition is overloaded after it\'s too late'
          },
          {
            id: 'c',
            thought: 'the partition key is wrong. user_id guarantees this happens again for any high-volume account',
            message: 'the partition key is wrong. user_id guarantees this happens again for any high-volume account'
          },
        ],
      }
    ],
  },
]

export { INCIDENT_MESSAGES, AUTH_INCIDENT_MESSAGES, PARTITIONING_INCIDENT_MESSAGES }