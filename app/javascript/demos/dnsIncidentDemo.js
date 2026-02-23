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
  // Message 0: Demo intro from Jacob
  {
    id: 'msg_intro',
    sequence: 0,
    author: { name: 'Jacob Comer', avatar: '/jacob-square.jpg' },
    accent: true,
    components: [
      {
        type: 'text',
        content: 'You\'re the on-call engineer. Connection pool just hit 98%. Follow along and make the call when it\'s your turn.',
      },
    ],
  },
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
        dataPoints: [10, 12, 14, 14, 14, 28, 32, 35, 35, 35, 52, 58, 62, 62, 62, 78, 82, 85, 85, 85, 92, 95, 96, 96, 96, 98, 98, 98, 98, 98],
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
        question: "The team reverted the change, but the underlying problem remains: orders can still be double-processed. What's the right architectural fix?",
        options: [
          {
            id: 'a',
            thought: 'Use SELECT FOR UPDATE SKIP LOCKED to avoid blocking',
            message: 'for the follow-up ticket — we could use SKIP LOCKED instead of FOR UPDATE. that way workers skip rows that are already being processed instead of blocking'
          },
          {
            id: 'b',
            thought: 'Add a distributed lock service like Redis or Zookeeper',
            message: 'thinking we need a distributed lock here — Redis or ZK. database row locks aren\'t meant for this kind of coordination'
          },
          {
            id: 'c',
            thought: 'Use a proper job queue with exactly-once delivery guarantees',
            message: 'this needs a proper job queue with exactly-once semantics. SQS FIFO or something similar — row locking for job coordination is always going to be fragile'
          },
          {
            id: 'd',
            thought: 'Increase the connection pool size to handle lock contention',
            message: 'should we just bump the connection pool? might give us more headroom for lock contention'
          },
        ],
      }
    ],
  },
]

export { INCIDENT_MESSAGES }