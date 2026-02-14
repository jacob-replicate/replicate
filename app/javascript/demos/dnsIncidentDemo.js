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
        additions: 4,
        deletions: 0,
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
    thread: [
      { avatar: '/profile-photo-1.jpg', name: 'sarah', time: '3:16 AM', text: 'that was me... thought it would catch DNS outages early 😅' },
      { avatar: '/profile-photo-2.jpg', name: 'daniel', time: '3:17 AM', text: '200 pods × 10 queries/sec = 2000 DNS queries/sec' },
      { avatar: '/profile-photo-1.jpg', name: 'sarah', time: '3:17 AM', text: 'oh god' },
      { avatar: '/profile-photo-3.jpg', name: 'maya', time: '3:17 AM', text: 'CoreDNS default is 1000 qps per instance lol' },
      { avatar: '/profile-photo-2.jpg', name: 'daniel', time: '3:18 AM', text: 'we have 2 replicas so you literally doubled our max capacity' },
      { avatar: '/profile-photo-1.jpg', name: 'sarah', time: '3:18 AM', text: 'rolling back now 🏃‍♀️' },
      { avatar: '/profile-photo-3.jpg', name: 'maya', time: '3:18 AM', text: '🙏' },
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
  {
    id: 'msg_5',
    author: { name: 'replicate.info', avatar: '/logo.png' },
    components: [
      {
        sequence: 7,
        type: 'multiple_choice',
        question: "What's the core issue with this DNS health check pattern?",
        selected: 'a',
        options: [
          { id: 'a', text: 'High-frequency polling overwhelms shared infrastructure like CoreDNS' },
          { id: 'b', text: 'External DNS lookups should use a caching resolver' },
          { id: 'c', text: 'The ndots:5 setting amplifies every query into multiple requests' },
        ],
      }
    ],
  },
]

// Start streaming when API is ready
window.ReplicateConversation.onReady((api) => {
  api.streamMessages(DNS_INCIDENT_MESSAGES)
})