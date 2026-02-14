/**
 * Demo script - streams the DNS incident conversation on page load
 * Uses the global ReplicateConversation API
 */

const DNS_INCIDENT_MESSAGES = [
  {
    id: 'msg_1',
    author: { name: 'PagerDuty', avatar: '/jacob-square.jpg' },
    components: [
      {
        sequence: 1,
        type: 'alert',
        color: 'red',
        title: '[SEV-1] DNS resolution failures across prod-east',
        description: "Services can't resolve internal hostnames",
        /* meta: 'payments-api, orders-api, auth-service affected • 847 errors/min', */ // This one gets cut from UI too
      }
    ],
    reactions: [
      { emoji: '📌', count: 1 },
      { emoji: '👀', count: 2 }
    ]
  },
  {
    id: 'msg_2',
    author: { name: 'maya', avatar: '/profile-photo-3.jpg' },
    components: [
      {
        sequence: 2,
        type: 'text',
        content: 'CoreDNS pods are OOMKilled — check the ndots setting in resolv.conf',
      },
      {
        sequence: 3,
        type: 'code',
        content: `# /etc/resolv.conf in affected pods
nameserver 10.96.0.10
search default.svc.cluster.local svc.cluster.local cluster.local
options ndots:5  # <- every lookup tries 5 suffixes first`,
      }
    ]
  },
  {
    id: 'msg_3',
    author: { name: 'daniel', avatar: '/profile-photo-2.jpg' },
    components: [
      {
        sequence: 4,
        type: 'text',
        content: 'found it — someone deployed a new sidecar that does nslookup every 100ms for health checks',
      },
      {
        sequence: 5,
        type: 'diff',
        filename: 'k8s/deployments/payments-api.yaml',
        lines: [
          { type: 'context', text: 'containers:' },
          { type: 'add', text: '- name: dns-health-checker' },
          { type: 'add', text: '  image: busybox' },
          { type: 'add', text: '  command: ["sh", "-c", "while true; do nslookup google.com; sleep 0.1; done"]' },
        ],
      }
    ],
    reactions: [
      { emoji: '💀', count: 3 },
      { emoji: '🤦', count: 2 },
    ],
  },
  // First thread reply - sarah admits fault
  {
    id: 'msg_3_reply_1',
    parent_message_id: 'msg_3',
    author: { name: 'sarah', avatar: '/profile-photo-1.jpg' },
    timestamp: '2026-02-14T03:16:00',
    components: [
      { sequence: 5.1, type: 'text', content: 'that was me... thought it would catch DNS outages early 😅' }
    ],
  },
  {
    id: 'msg_4',
    author: { name: 'maya', avatar: '/profile-photo-3.jpg' },
    components: [
      {
        sequence: 6,
        type: 'text',
        content: 'rollback is out — DNS queries dropping back to normal. @oncall let\'s add CoreDNS autoscaling before this happens again',
      }
    ],
  },
  // More thread replies interspersed
  {
    id: 'msg_3_reply_2',
    parent_message_id: 'msg_3',
    author: { name: 'daniel', avatar: '/profile-photo-2.jpg' },
    timestamp: '2026-02-14T03:17:00',
    components: [
      { sequence: 6.1, type: 'text', content: '200 pods × 10 queries/sec = 2000 DNS queries/sec' }
    ],
  },
  {
    id: 'msg_5',
    author: { name: 'replicate.info', avatar: '/logo.png' },
    components: [
      {
        sequence: 7,
        type: 'multiple_choice',
        question: "Rollback is out. What's your next move?",
        selected: 'a',
        options: [
          { id: 'a', text: 'Scale CoreDNS to handle the load, then close the incident' },
          { id: 'b', text: 'Check if other services have similar polling patterns' },
          { id: 'c', text: 'Lower ndots to reduce query amplification cluster-wide' },
        ],
      }
    ],
  },
  {
    id: 'msg_3_reply_3',
    parent_message_id: 'msg_3',
    author: { name: 'sarah', avatar: '/profile-photo-1.jpg' },
    timestamp: '2026-02-14T03:17:30',
    components: [
      { sequence: 7.1, type: 'text', content: 'oh god' }
    ],
  },
  {
    id: 'msg_6',
    author: { name: 'daniel', avatar: '/profile-photo-2.jpg' },
    components: [
      {
        sequence: 8,
        type: 'text',
        content: 'scaled CoreDNS to 4 replicas. should be good now',
      }
    ],
  },
  {
    id: 'msg_3_reply_4',
    parent_message_id: 'msg_3',
    author: { name: 'maya', avatar: '/profile-photo-3.jpg' },
    timestamp: '2026-02-14T03:17:45',
    components: [
      { sequence: 8.1, type: 'text', content: 'CoreDNS default is 1000 qps per instance lol' }
    ],
  },
  {
    id: 'msg_7',
    author: { name: 'maya', avatar: '/profile-photo-3.jpg' },
    components: [
      {
        sequence: 9,
        type: 'text',
        content: 'wait. I just grepped for nslookup across the cluster',
      },
      {
        sequence: 10,
        type: 'code',
        content: `$ grep -r "nslookup\\|dns\\|resolve" */health*.yaml | wc -l
47`,
      }
    ],
  },
  {
    id: 'msg_3_reply_5',
    parent_message_id: 'msg_3',
    author: { name: 'daniel', avatar: '/profile-photo-2.jpg' },
    timestamp: '2026-02-14T03:18:00',
    components: [
      { sequence: 10.1, type: 'text', content: 'we have 2 replicas so you literally doubled our max capacity' }
    ],
  },
  {
    id: 'msg_8',
    author: { name: 'daniel', avatar: '/profile-photo-2.jpg' },
    components: [
      {
        sequence: 11,
        type: 'text',
        content: 'forty seven services doing DNS health checks. and auth-service alone has 400 replicas doing 1 lookup/sec each',
      }
    ],
    reactions: [
      { emoji: '😬', count: 3 },
    ],
  },
  {
    id: 'msg_3_reply_6',
    parent_message_id: 'msg_3',
    author: { name: 'sarah', avatar: '/profile-photo-1.jpg' },
    timestamp: '2026-02-14T03:18:15',
    components: [
      { sequence: 11.1, type: 'text', content: 'rolling back now 🏃‍♀️' }
    ],
  },
  {
    id: 'msg_9',
    author: { name: 'replicate.info', avatar: '/logo.png' },
    components: [
      {
        sequence: 12,
        type: 'multiple_choice',
        question: "With ndots:5, each lookup generates up to 6 queries. What's the actual baseline load on CoreDNS right now?",
        selected: 'b',
        options: [
          { id: 'a', text: 'Somewhere around 2000 qps' },
          { id: 'b', text: 'Closer to 15000 qps if you count the search domains' },
        ],
      }
    ],
  },
  {
    id: 'msg_3_reply_7',
    parent_message_id: 'msg_3',
    author: { name: 'maya', avatar: '/profile-photo-3.jpg' },
    timestamp: '2026-02-14T03:18:30',
    components: [
      { sequence: 12.1, type: 'text', content: '🙏' }
    ],
  },
  {
    id: 'msg_10',
    author: { name: 'maya', avatar: '/profile-photo-3.jpg' },
    components: [
      {
        sequence: 13,
        type: 'text',
        content: 'we just scaled to 4 replicas. thats 4000 qps max. we were over capacity before the incident even started',
      }
    ],
  },
  {
    id: 'msg_11',
    author: { name: 'daniel', avatar: '/profile-photo-2.jpg' },
    components: [
      {
        sequence: 14,
        type: 'text',
        content: 'the payments sidecar wasnt the root cause. it was the last 2000 qps on a system already doing 15000',
      }
    ],
    reactions: [
      { emoji: '💀', count: 2 },
    ],
  },
  {
    id: 'msg_12',
    author: { name: 'replicate.info', avatar: '/logo.png' },
    components: [
      {
        sequence: 15,
        type: 'text',
        content: "You scale CoreDNS to 20 replicas. Next Tuesday, auth-service rolls out and all 400 pods restart at once. What breaks first?",
      }
    ],
  },
]

// Start streaming when API is ready
window.ReplicateConversation.onReady((api) => {
  api.streamMessages(DNS_INCIDENT_MESSAGES)
})