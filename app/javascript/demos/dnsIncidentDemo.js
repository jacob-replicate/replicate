/**
 * Demo script - streams the DNS incident conversation on page load
 * Uses the global ReplicateConversation API
 */

const DNS_INCIDENT_MESSAGES = [
  {
    id: 'msg_1',
    sequence: 1,
    author: { name: 'PagerDuty', avatar: '/jacob-square.jpg' },
    created_at: '2026-02-14T10:30:00',
    components: [
      {
        type: 'alert',
        color: 'red',
        title: '[SEV-1] DNS resolution failures across prod-east',
        description: "Services can't resolve internal hostnames",
      }
    ],
    reactions: [
      { emoji: '📌', count: 1 },
      { emoji: '👀', count: 2 }
    ]
  },
  {
    id: 'msg_2',
    sequence: 2,
    author: { name: 'maya', avatar: '/profile-photo-3.jpg' },
    created_at: '2026-02-14T10:31:00',
    components: [
      {
        type: 'text',
        content: 'CoreDNS pods are OOMKilled — check the ndots setting in resolv.conf',
      },
      {
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
    sequence: 3,
    author: { name: 'daniel', avatar: '/profile-photo-2.jpg' },
    created_at: '2026-02-14T10:32:00',
    components: [
      {
        type: 'text',
        content: 'found it — someone deployed a new sidecar that does nslookup every 100ms for health checks',
      },
      {
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
  {
    id: 'msg_4',
    sequence: 4,
    parent_message_id: 'msg_3',
    author: { name: 'sarah', avatar: '/profile-photo-1.jpg' },
    created_at: '2026-02-14T10:33:00',
    components: [
      { type: 'text', content: 'that was me... thought it would catch DNS outages early 😅' }
    ],
  },
  {
    id: 'msg_5',
    sequence: 5,
    author: { name: 'maya', avatar: '/profile-photo-3.jpg' },
    created_at: '2026-02-14T10:34:00',
    updated_at: '2026-02-14T10:35:00',
    components: [
      {
        type: 'text',
        content: 'rollback is out — DNS queries dropping back to normal. @oncall let\'s add CoreDNS autoscaling before this happens again',
      }
    ],
  },
  {
    id: 'msg_6',
    sequence: 6,
    parent_message_id: 'msg_3',
    author: { name: 'daniel', avatar: '/profile-photo-2.jpg' },
    created_at: '2026-02-14T10:34:30',
    components: [
      { type: 'text', content: '200 pods × 10 queries/sec = 2000 DNS queries/sec' }
    ],
  },
  {
    id: 'msg_7',
    sequence: 7,
    author: { name: 'invariant.training', avatar: '/logo.png' },
    created_at: '2026-02-14T10:35:00',
    components: [
      {
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
    id: 'msg_8',
    sequence: 8,
    parent_message_id: 'msg_3',
    author: { name: 'sarah', avatar: '/profile-photo-1.jpg' },
    created_at: '2026-02-14T10:35:30',
    components: [
      { type: 'text', content: 'oh god' }
    ],
  },
  {
    id: 'msg_9',
    sequence: 9,
    author: { name: 'daniel', avatar: '/profile-photo-2.jpg' },
    created_at: '2026-02-14T10:36:00',
    components: [
      {
        type: 'text',
        content: 'scaled CoreDNS to 4 replicas. should be good now',
      }
    ],
  },
  {
    id: 'msg_10',
    sequence: 10,
    parent_message_id: 'msg_3',
    author: { name: 'maya', avatar: '/profile-photo-3.jpg' },
    created_at: '2026-02-14T10:36:30',
    components: [
      { type: 'text', content: 'CoreDNS default is 1000 qps per instance lol' }
    ],
  },
  {
    id: 'msg_11',
    sequence: 11,
    author: { name: 'maya', avatar: '/profile-photo-3.jpg' },
    created_at: '2026-02-14T10:37:00',
    components: [
      {
        type: 'text',
        content: 'wait. I just grepped for nslookup across the cluster',
      },
      {
        type: 'code',
        content: `$ grep -r "nslookup\\|dns\\|resolve" */health*.yaml | wc -l
47`,
      }
    ],
  },
  {
    id: 'msg_12',
    sequence: 12,
    parent_message_id: 'msg_3',
    author: { name: 'daniel', avatar: '/profile-photo-2.jpg' },
    created_at: '2026-02-14T10:37:30',
    components: [
      { type: 'text', content: 'we have 2 replicas so you literally doubled our max capacity' }
    ],
  },
  {
    id: 'msg_13',
    sequence: 13,
    author: { name: 'daniel', avatar: '/profile-photo-2.jpg' },
    created_at: '2026-02-14T10:38:00',
    components: [
      {
        type: 'text',
        content: 'forty seven services doing DNS health checks. and auth-service alone has 400 replicas doing 1 lookup/sec each',
      }
    ],
    reactions: [
      { emoji: '😬', count: 3 },
    ],
  },
  {
    id: 'msg_14',
    sequence: 14,
    parent_message_id: 'msg_3',
    author: { name: 'sarah', avatar: '/profile-photo-1.jpg' },
    created_at: '2026-02-14T10:38:30',
    updated_at: '2026-02-14T10:39:00',
    components: [
      { type: 'text', content: 'rolling back now 🏃‍♀️' }
    ],
  },
  {
    id: 'msg_15',
    sequence: 15,
    author: { name: 'invariant.training', avatar: '/logo.png' },
    created_at: '2026-02-14T10:39:00',
    components: [
      {
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
    id: 'msg_16',
    sequence: 16,
    parent_message_id: 'msg_3',
    author: { name: 'maya', avatar: '/profile-photo-3.jpg' },
    created_at: '2026-02-14T10:39:30',
    components: [
      { type: 'text', content: '🙏' }
    ],
  },
  {
    id: 'msg_17',
    sequence: 17,
    author: { name: 'maya', avatar: '/profile-photo-3.jpg' },
    created_at: '2026-02-14T10:40:00',
    components: [
      {
        type: 'text',
        content: 'we just scaled to 4 replicas. thats 4000 qps max. we were over capacity before the incident even started',
      }
    ],
  },
  {
    id: 'msg_18',
    sequence: 18,
    author: { name: 'daniel', avatar: '/profile-photo-2.jpg' },
    created_at: '2026-02-14T10:41:00',
    components: [
      {
        type: 'text',
        content: 'the payments sidecar wasnt the root cause. it was the last 2000 qps on a system already doing 15000',
      }
    ],
    reactions: [
      { emoji: '💀', count: 2 },
    ],
  },
  {
    id: 'msg_19',
    sequence: 19,
    author: { name: 'invariant.training', avatar: '/logo.png' },
    created_at: '2026-02-14T10:42:00',
    components: [
      {
        type: 'text',
        content: "You scale CoreDNS to 20 replicas. Next Tuesday, auth-service rolls out and all 400 pods restart at once. What breaks first?",
      }
    ],
  },
]
]

// Demo conversation UUID
const DEMO_CONVERSATION_ID = 'c9f2e8d1-3b4a-5c6d-7e8f-9a0b1c2d3e4f'

/**
 * Simulates fetching a conversation from /conversations/generate
 * In production, this would be a real API call
 */
const fetchConversation = async () => {
  // Simulate API response - in production this would be:
  // const response = await fetch('/conversations/generate')
  // return response.json()

  // Check if we navigated directly to this conversation (existing) or from root (new)
  const isDirectNavigation = window.location.pathname.includes('/conversations/')

  return {
    id: DEMO_CONVERSATION_ID,
    channel_name: '#ops-alerts',
    is_new: !isDirectNavigation, // Direct navigation = existing, root = new demo
    messages: DNS_INCIDENT_MESSAGES,
  }
}

/**
 * Initialize the conversation demo
 *
 * Two scenarios:
 * 1. User lands on root (/) - navigate to conversation, stream with animations
 * 2. User lands directly on /conversations/:uuid - load instantly, no animations
 */
const initConversation = async () => {
  // Fetch conversation data
  const conversation = await fetchConversation()
  const targetUrl = `/conversations/${conversation.id}`
  const isAlreadyOnConversation = window.location.pathname === targetUrl

  // Wait for the API to be ready
  const waitForReady = () => {
    if (window.ReplicateConversation?.navigate) {
      // Navigate if not already there
      if (!isAlreadyOnConversation) {
        window.ReplicateConversation.navigate(targetUrl)
      }

      // Wait for the conversation view to be ready after navigation
      window.ReplicateConversation.onReady((api) => {
        // Set channel name
        api.setChannelName(conversation.channel_name)

        if (conversation.is_new) {
          // New conversation - stream with typing animations
          api.streamMessages(conversation.messages)
        } else {
          // Existing conversation - load instantly without animations
          api.loadMessages(conversation.messages)
        }
      })
    } else {
      // Navigate not ready yet, wait a bit
      setTimeout(waitForReady, 50)
    }
  }

  waitForReady()
}

// Start when DOM is ready
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initConversation)
} else {
  initConversation()
}