/**
 * Demo script - streams the DNS incident conversation on page load
 * Uses the global ReplicateConversation API
 */

const DNS_INCIDENT_MESSAGES = [
  {
    delay: 800,
    typingDuration: 1200,
    message: {
      author: { name: 'pagerduty', avatar: '/jacob-square.jpg' },
      type: 'alert',
      content: 'DNS resolution failures across prod-east',
      metadata: {
        severity: 'SEV-1',
        title: 'DNS resolution failures across prod-east',
        description: "Services can't resolve internal hostnames — 503s spiking",
        meta: 'payments-api, orders-api, auth-service affected • 847 errors/min',
        reactions: [
          { emoji: '📌', count: 1 },
          { emoji: '👀', count: 5 },
        ],
      },
    },
  },
  {
    delay: 600,
    typingDuration: 1600,
    message: {
      author: { name: 'maya', avatar: '/profile-photo-3.jpg' },
      type: 'text',
      content: 'CoreDNS pods are OOMKilled — check the ndots setting in resolv.conf',
    },
  },
  {
    delay: 400,
    typingDuration: 0,
    message: {
      author: { name: 'maya', avatar: '/profile-photo-3.jpg' },
      type: 'code',
      content: `# /etc/resolv.conf in affected pods
nameserver 10.96.0.10
search default.svc.cluster.local svc.cluster.local cluster.local
options ndots:5  # <- every lookup tries 5 suffixes first`,
      metadata: {
        language: 'yaml',
        thread: [
          { avatar: '/profile-photo-1.jpg', name: 'alex', time: '3:14 AM', text: 'wait so payments-api.prod hits the DNS server 6 times?' },
          { avatar: '/profile-photo-3.jpg', name: 'maya', time: '3:15 AM', text: 'yep — it tries all the search domains before going external' },
          { avatar: '/profile-photo-1.jpg', name: 'alex', time: '3:15 AM', text: 'thats insane, no wonder coredns is dying 😬' },
        ],
      },
    },
  },
  {
    delay: 800,
    typingDuration: 1200,
    message: {
      author: { name: 'daniel', avatar: '/profile-photo-2.jpg' },
      type: 'text',
      content: 'found it — someone deployed a new sidecar that does nslookup every 100ms for health checks',
    },
  },
  {
    delay: 400,
    typingDuration: 0,
    message: {
      author: { name: 'daniel', avatar: '/profile-photo-2.jpg' },
      type: 'diff',
      content: '',
      metadata: {
        filename: 'k8s/deployments/payments-api.yaml',
        additions: 4,
        deletions: 0,
        lines: [
          { type: 'context', text: 'containers:' },
          { type: 'add', text: '- name: dns-health-checker' },
          { type: 'add', text: '  image: busybox' },
          { type: 'add', text: '  command: ["sh", "-c", "while true; do nslookup google.com; sleep 0.1; done"]' },
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
    },
  },
  {
    delay: 600,
    typingDuration: 1400,
    message: {
      author: { name: 'maya', avatar: '/profile-photo-3.jpg' },
      type: 'text',
      content: 'rollback is out — DNS queries dropping back to normal. @oncall let\'s add CoreDNS autoscaling before this happens again',
      metadata: {
        edited: true,
      },
    },
  },
  {
    delay: 800,
    typingDuration: 700,
    message: {
      author: { name: 'replicate.info', avatar: '/logo.png' },
      type: 'multiple_choice',
      content: "What's the core issue with this DNS health check pattern?",
      metadata: {
        options: [
          { id: 'a', text: 'High-frequency polling overwhelms shared infrastructure like CoreDNS' },
          { id: 'b', text: 'External DNS lookups should use a caching resolver' },
          { id: 'c', text: 'The ndots:5 setting amplifies every query into multiple requests' },
        ],
      },
    },
  },
]

/**
 * Stream messages with typing indicators and delays
 */
async function streamDemoConversation(api) {
  for (const item of DNS_INCIDENT_MESSAGES) {
    // Wait for delay
    if (item.delay > 0) {
      await sleep(item.delay)
    }

    // Show typing indicator
    if (item.typingDuration > 0) {
      api.setTyping(item.message.author)
      await sleep(item.typingDuration)
      api.setTyping(false)
    }

    // Add the message
    api.addMessage(item.message)
  }
}

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms))
}

// Start streaming when API is ready
window.ReplicateConversation.onReady((api) => {
  // Small delay to let the UI settle
  setTimeout(() => {
    streamDemoConversation(api)
  }, 300)
})