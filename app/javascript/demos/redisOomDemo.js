/**
 * Redis OOM Incident Demo - second conversation for tab switching
 * Uses the global ReplicateConversation API
 */

// Generate dynamic timestamps starting 8 minutes ago
const generateTimestamps = () => {
  const now = new Date()
  const startTime = new Date(now.getTime() - 8 * 60 * 1000) // 8 minutes ago

  const offsets = [
    0,      // msg_1: Alert
    45,     // msg_2: Sarah takes IC
    90,     // msg_3: Thread - chen asks
    120,    // msg_4: Thread - sarah responds
    180,    // msg_5: Chen finds memory spike
    240,    // msg_6: Thread - sarah asks about keys
    270,    // msg_7: Thread - chen checks
    330,    // msg_8: Chen finds the culprit
    390,    // msg_9: Sarah proposes fix
    420,    // msg_10: Thread - chen agrees
    450,    // msg_11: Thread - risk assessment
    510,    // msg_12: Narrator question
  ]

  return offsets.map(offset => {
    const time = new Date(startTime.getTime() + offset * 1000)
    return time.toISOString()
  })
}

const timestamps = generateTimestamps()

export const REDIS_INCIDENT_MESSAGES = [
  // Message 1: Monitor alert
  {
    id: 'redis_msg_1',
    sequence: 1,
    author: { name: 'ops-prod-alerts', avatar: '/logo.png' },
    created_at: timestamps[0],
    components: [
      {
        type: 'monitor',
        title: 'Redis Memory Usage',
        metric: 'cache-prod-1',
        value: 94,
        threshold: 85,
        status: 'critical',
      }
    ],
    reactions: [
      { emoji: '🚨', count: 3 },
      { emoji: '👀', count: 5 }
    ]
  },
  // Message 2: Sarah takes IC
  {
    id: 'redis_msg_2',
    sequence: 2,
    author: { name: 'sarah', avatar: '/profile-photo-1.jpg', status: { emoji: '🎧', text: 'In the zone' } },
    created_at: timestamps[1],
    components: [
      {
        type: 'text',
        content: 'on it. @chen can you check what\'s eating memory? we were at 60% this morning',
      },
    ]
  },
  // Message 3: Thread reply - chen asks
  {
    id: 'redis_msg_3',
    sequence: 3,
    parent_message_id: 'redis_msg_2',
    author: { name: 'chen', avatar: '/profile-photo-2.jpg' },
    created_at: timestamps[2],
    components: [
      { type: 'text', content: 'pulling memory analysis now — any recent deploys?' }
    ],
  },
  // Message 4: Thread reply - sarah responds
  {
    id: 'redis_msg_4',
    sequence: 4,
    parent_message_id: 'redis_msg_2',
    author: { name: 'sarah', avatar: '/profile-photo-1.jpg' },
    created_at: timestamps[3],
    components: [
      { type: 'text', content: 'recommendations service deployed ~2hrs ago, let me check the diff' }
    ],
  },
  // Message 5: Chen finds memory spike
  {
    id: 'redis_msg_5',
    sequence: 5,
    author: { name: 'chen', avatar: '/profile-photo-2.jpg' },
    created_at: timestamps[4],
    components: [
      {
        type: 'text',
        content: 'found the spike — memory jumped 30% right after that deploy. here\'s the breakdown:',
      },
      {
        type: 'code',
        language: 'bash',
        content: `$ redis-cli --bigkeys

# Scanning the entire keyspace to find biggest keys

[00.00%] Biggest string found so far 'session:a]1b7f2e' with 2048 bytes
[12.34%] Biggest list   found so far 'reco:user:*' with 847293 items
[45.67%] Biggest hash   found so far 'product:cache' with 12847 fields

-------- summary -------
Biggest   list found 'reco:pending:batch' has 2847293 items  # <-- this is new
Biggest string found 'session:*' has 4096 bytes
Biggest   hash found 'product:cache' has 12847 fields`,
      }
    ],
    reactions: [
      { emoji: '👀', count: 2 },
    ],
  },
  // Message 6: Thread - sarah asks about keys
  {
    id: 'redis_msg_6',
    sequence: 6,
    parent_message_id: 'redis_msg_5',
    author: { name: 'sarah', avatar: '/profile-photo-1.jpg' },
    created_at: timestamps[5],
    components: [
      { type: 'text', content: '2.8M items in a list?? what is reco:pending:batch?' }
    ],
  },
  // Message 7: Thread - chen checks
  {
    id: 'redis_msg_7',
    sequence: 7,
    parent_message_id: 'redis_msg_5',
    author: { name: 'chen', avatar: '/profile-photo-2.jpg' },
    created_at: timestamps[6],
    components: [
      { type: 'text', content: 'checking the new reco service code...' }
    ],
  },
  // Message 8: Chen finds the culprit
  {
    id: 'redis_msg_8',
    sequence: 8,
    author: { name: 'chen', avatar: '/profile-photo-2.jpg' },
    created_at: timestamps[7],
    components: [
      {
        type: 'text',
        content: 'found it — new batch processor is pushing to the list but the consumer crashed on startup and never drained it',
      },
      {
        type: 'diff',
        filename: 'services/recommendations/batch.py',
        lines: [
          { type: 'context', text: 'def enqueue_recommendations(user_ids):' },
          { type: 'context', text: '    for user_id in user_ids:' },
          { type: 'add', text: '        # Queue for async processing' },
          { type: 'add', text: '        redis.lpush("reco:pending:batch", json.dumps({' },
          { type: 'add', text: '            "user_id": user_id,' },
          { type: 'add', text: '            "timestamp": time.time()' },
          { type: 'add', text: '        }))' },
          { type: 'context', text: '        # No TTL, no max length check 💀' },
        ],
      },
      {
        type: 'text',
        content: 'no LTRIM, no maxlen, and the consumer pod is in CrashLoopBackOff',
      }
    ],
    reactions: [
      { emoji: '💀', count: 3 },
      { emoji: '🤦', count: 2 },
    ],
  },
  // Message 9: Sarah proposes fix
  {
    id: 'redis_msg_9',
    sequence: 9,
    author: { name: 'sarah', avatar: '/profile-photo-1.jpg' },
    created_at: timestamps[8],
    components: [
      {
        type: 'text',
        content: 'okay two things: (1) fix the consumer pod, (2) trim the list to something sane. chen can you restart the consumer while I trim?',
      },
      {
        type: 'code',
        language: 'bash',
        content: `# Keep only the most recent 10k items
$ redis-cli LTRIM reco:pending:batch -10000 -1

# Verify
$ redis-cli LLEN reco:pending:batch
(integer) 10000`,
      }
    ],
  },
  // Message 10: Thread - chen agrees
  {
    id: 'redis_msg_10',
    sequence: 10,
    parent_message_id: 'redis_msg_9',
    author: { name: 'chen', avatar: '/profile-photo-2.jpg' },
    created_at: timestamps[9],
    components: [
      { type: 'text', content: 'on it — consumer was missing a env var for the redis password, fixing now' }
    ],
  },
  // Message 11: Thread - risk assessment
  {
    id: 'redis_msg_11',
    sequence: 11,
    parent_message_id: 'redis_msg_9',
    author: { name: 'sarah', avatar: '/profile-photo-1.jpg' },
    created_at: timestamps[10],
    components: [
      { type: 'text', content: 'trimming 2.8M items means we lose those reco jobs — but they\'re stale anyway, users will get fresh ones on next login' }
    ],
  },
  // Message 12: Narrator question
  {
    id: 'redis_msg_12',
    sequence: 12,
    author: { name: 'invariant', avatar: '/logo.png' },
    created_at: timestamps[11],
    isSystem: true,
    components: [
      {
        type: 'multiple_choice',
        question: 'The immediate fix is to trim the list and restart the consumer. What architectural change would prevent this from happening again?',
        options: [
          {
            id: 'a',
            thought: 'Add MAXLEN to the LPUSH command to cap list size',
            message: 'we should add MAXLEN to the LPUSH — that way the list self-prunes and can\'t grow unbounded even if the consumer dies'
          },
          {
            id: 'b',
            thought: 'Use Redis Streams instead of Lists for the queue',
            message: 'this is a job queue pattern — we should use Redis Streams instead of Lists. streams have built-in consumer groups, acks, and MAXLEN'
          },
          {
            id: 'c',
            thought: 'Add memory alerts earlier at 70% threshold',
            message: 'we need earlier alerting — if we caught this at 70% we\'d have more time to respond'
          },
          {
            id: 'd',
            thought: 'Move to a proper message queue like SQS or RabbitMQ',
            message: 'redis isn\'t really meant for durable job queues — should we move this to SQS or RabbitMQ?'
          },
        ],
      }
    ],
  },
]

// Demo conversation UUID for Redis incident
export const REDIS_DEMO_CONVERSATION_ID = 'redis-oom-incident-demo'