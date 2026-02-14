import React from 'react'
import { Link } from 'react-router-dom'

// ===========================================
// POLISHED INCIDENT WIDGETS - DO NOT PURGE
// ===========================================
// These are the keepers. Add new polished widgets here.

const LIVE_INCIDENTS = [
  {
    service: 'user-service',
    alert: 'Connection pool exhausted',
    metric: '0 available connections',
    time: '1 min ago',
    slug: 'resource-limits',
  },
  {
    service: 'payments-api',
    alert: 'POST /payments returning 500s',
    metric: '47% error rate',
    time: '3 min ago',
    slug: 'transactions',
  },
  {
    service: 'search-cluster',
    alert: 'Node election in progress',
    metric: '2/5 nodes unreachable',
    time: '45 sec ago',
    slug: 'consensus',
  },
  {
    service: 'cache-layer',
    alert: 'Redis cluster split-brain detected',
    metric: '2 masters elected',
    time: '30 sec ago',
    slug: 'caching',
  },
  {
    service: 'orders-api',
    alert: 'Deadlock detected in transaction',
    metric: '12 queries waiting',
    time: '1 min ago',
    slug: 'transactions',
  },
]

// PagerDuty SEV-1 alert style
export const PagerDutyAlert = () => {
  const incident = LIVE_INCIDENTS[0]
  return (
    <div className="py-4">
      <a
        href={`/topics/${incident.slug}`}
        className="block p-4 rounded-lg bg-zinc-800 hover:bg-zinc-700/80 transition-colors group border border-zinc-700"
      >
        <div className="flex items-center justify-between gap-4">
          <div className="flex items-center gap-3 flex-1 min-w-0">
            <div className="w-2 h-2 rounded-full bg-red-500 animate-pulse flex-shrink-0"></div>
            <div className="flex-1 min-w-0">
              <div className="flex items-center gap-2 mb-1">
                <span className="text-white font-medium">prod-api-gateway</span>
                <span className="px-1.5 py-0.5 rounded text-xs font-bold bg-red-500/20 text-red-400 border border-red-500/30">SEV-1</span>
              </div>
              <div className="text-zinc-400 text-sm mb-2">{incident.alert}</div>
              <div className="flex items-center gap-3 text-xs">
                <span className="font-mono text-red-400 bg-red-500/10 px-1.5 py-0.5 rounded">ECONNREFUSED</span>
                <span className="text-zinc-400">~2,847 users affected</span>
                <span className="text-zinc-500">•</span>
                <span className="text-zinc-400 font-mono">a]1b7f2e</span>
              </div>
            </div>
          </div>
          <div className="px-5 py-2.5 rounded bg-white hover:bg-white/90 text-zinc-900 text-sm font-medium transition-colors tracking-normal">
            Respond →
          </div>
        </div>
      </a>
    </div>
  )
}

// Datadog-style monitor warning alert
export const MonitorAlert = () => {
  const [dataPoints, setDataPoints] = React.useState(() => {
    // Initialize with a crescendo - starting at 13% and building up near the threshold
    const initial = []
    for (let i = 0; i < 20; i++) {
      // Start around 13%, end around 76-78% (just under the 80% threshold)
      const progress = i / 19
      const base = 13 + progress * 65 // 13% -> 78%
      const noise = (Math.random() - 0.5) * 3
      initial.push(base + noise)
    }
    return initial
  })

  React.useEffect(() => {
    // Add new data point every 5 seconds, hovering near the threshold
    const interval = setInterval(() => {
      setDataPoints(prev => {
        const newPoints = [...prev.slice(1)]
        const lastVal = prev[prev.length - 1]
        // Hover around 76-80%, slight upward bias
        const drift = (Math.random() - 0.45) * 2
        const newVal = Math.max(74, Math.min(81, lastVal + drift))
        newPoints.push(newVal)
        return newPoints
      })
    }, 5000)
    return () => clearInterval(interval)
  }, [])

  // Convert percentage values to SVG y coordinates (0% = y:40, 100% = y:0)
  const toY = (pct) => 40 - (pct / 100) * 40

  const points = dataPoints.map((val, i) => {
    const x = (i / (dataPoints.length - 1)) * 200
    const y = toY(val)
    return `${x},${y}`
  })
  const linePath = `M${points.join(' L')}`
  const areaPath = `${linePath} L200,40 L0,40 Z`
  const currentValue = Math.round(dataPoints[dataPoints.length - 1])
  const lastY = toY(dataPoints[dataPoints.length - 1])

  return (
    <div className="py-4">
      <a
        href="/topics/postgres-internals"
        className="block rounded-xl overflow-hidden transition-all hover:shadow-lg border-2 border-amber-300"
        style={{ backgroundColor: '#fffbeb' }}
      >
        {/* Header */}
        <div className="px-5 pt-4 pb-3 flex items-center justify-between">
          <div className="flex items-center gap-2">
            <svg className="w-5 h-5 text-amber-600" viewBox="0 0 24 24" fill="currentColor">
              <rect x="3" y="4" width="18" height="4" rx="1" opacity="0.5" />
              <rect x="3" y="10" width="18" height="4" rx="1" opacity="0.7" />
              <rect x="3" y="16" width="18" height="4" rx="1" />
            </svg>
            <span className="text-amber-800 font-medium text-sm">Monitor Alert</span>
          </div>
          <span className="px-3 py-1.5 rounded text-sm font-semibold bg-zinc-600 text-white">Warning</span>
        </div>

        {/* Content */}
        <div className="px-5 pb-2">
          <h3 className="text-zinc-900 text-xl font-semibold mb-1.5">MultiXact SLRU nearing wraparound</h3>
          <div className="flex items-center gap-2 text-amber-700 text-sm">
            <span>prod-primary</span>
            <span className="opacity-50">•</span>
            <span>{currentValue}% of member space consumed</span>
          </div>
        </div>

        {/* Time-series area chart with threshold */}
        <div className="px-5 pb-3 pt-2">
          {/* 80% threshold label */}
          <div className="flex justify-end mb-1">
            <span className="text-[10px] text-red-400 font-medium">80%</span>
          </div>
          {/* Chart container */}
          <div className="relative">
            {/* Threshold line at 80% */}
            <div className="absolute w-full border-t-2 border-dashed border-red-400/60" style={{ top: `${(1 - 0.80) * 48}px` }} />
            {/* Area chart SVG */}
            <svg viewBox="0 0 200 40" className="w-full h-12" preserveAspectRatio="none">
              {/* Gradient fill */}
              <defs>
                <linearGradient id="slruGradient" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="0%" stopColor="#f59e0b" stopOpacity="0.4" />
                  <stop offset="100%" stopColor="#fbbf24" stopOpacity="0.1" />
                </linearGradient>
              </defs>
              {/* Area path */}
              <path d={areaPath} fill="url(#slruGradient)" />
              {/* Line on top */}
              <path
                d={linePath}
                fill="none"
                stroke="#f59e0b"
                strokeWidth="2"
                strokeLinecap="round"
                strokeLinejoin="round"
              />
              {/* Pulsing dot at current value */}
              <circle cx="200" cy={lastY} r="3" fill="#f59e0b">
                <animate attributeName="r" values="3;5;3" dur="1s" repeatCount="indefinite" />
                <animate attributeName="opacity" values="1;0.6;1" dur="1s" repeatCount="indefinite" />
              </circle>
            </svg>
          </div>
          {/* Time labels */}
          <div className="flex justify-between text-[10px] text-amber-600/70 mt-1">
            <span>30m ago</span>
            <span>now</span>
          </div>
        </div>
      </a>
    </div>
  )
}

// Inline code span component
const Code = ({ children }) => (
  <span className="font-mono bg-zinc-100 dark:bg-zinc-800 px-1 rounded">{children}</span>
)

// Mention component
const Mention = ({ children }) => (
  <span className="text-[#1264a3] dark:text-blue-400 bg-[#e8f5fa] dark:bg-blue-900/30 rounded px-0.5 font-medium">{children}</span>
)

// Emoji reaction pill component
const EmojiReaction = ({ emoji, count }) => (
  <span className="inline-flex items-center gap-1 px-1.5 py-0.5 rounded-full bg-zinc-100 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-xs">
    <span>{emoji}</span>
    <span className="text-zinc-600 dark:text-zinc-400">{count}</span>
  </span>
)

// Message text wrapper - handles styling consistently
const MessageText = ({ children, className = '' }) => (
  <div className={`text-[#1d1c1d] dark:text-zinc-200 text-[15px] ${className}`}>{children}</div>
)

// Reusable diff component
// lines: array of { text: string, type: 'add' | 'remove' | 'context' }
export const Diff = ({ filename, lines, additions, deletions }) => (
  <div className="rounded border border-zinc-200 dark:border-zinc-700 overflow-hidden text-[12px] font-mono">
    {filename && (
      <div className="bg-zinc-100 dark:bg-zinc-800 px-2 py-1 text-zinc-500 dark:text-zinc-400 border-b border-zinc-200 dark:border-zinc-700 flex items-center justify-between">
        <span>{filename}</span>
        {(additions || deletions) && (
          <div className="flex items-center gap-2">
            {additions && <span className="text-green-600 dark:text-green-400">+{additions}</span>}
            {deletions && <span className="text-red-500 dark:text-red-400">-{deletions}</span>}
          </div>
        )}
      </div>
    )}
    {lines.map((line, i) => {
      if (line.type === 'remove') {
        return (
          <div key={i} className="bg-red-50 dark:bg-red-950/30 px-2 py-0.5 text-red-700 dark:text-red-300">
            <span className="text-red-400 dark:text-red-500 select-none mr-2">-</span>
            {line.text}
          </div>
        )
      }
      if (line.type === 'add') {
        return (
          <div key={i} className="bg-green-50 dark:bg-green-950/30 px-2 py-0.5 text-green-700 dark:text-green-300">
            <span className="text-green-500 select-none mr-2">+</span>
            {line.text}
          </div>
        )
      }
      // context
      return (
        <div key={i} className="px-2 py-0.5 text-zinc-600 dark:text-zinc-400">
          <span className="select-none mr-2">&nbsp;</span>
          {line.text}
        </div>
      )
    })}
  </div>
)

// Thread reply link component with expandable replies
const Thread = ({ replies }) => {
  const [expanded, setExpanded] = React.useState(false)
  const [visibleReplies, setVisibleReplies] = React.useState(0)

  // Trickle in replies when expanded
  React.useEffect(() => {
    if (!expanded || visibleReplies >= replies.length) return

    const timeout = setTimeout(() => {
      setVisibleReplies(v => v + 1)
    }, visibleReplies === 0 ? 300 : 800 + Math.random() * 600)

    return () => clearTimeout(timeout)
  }, [expanded, visibleReplies, replies.length])

  const lastReply = replies[replies.length - 1]

  return (
    <div className="mt-2">
      <button
        onClick={() => setExpanded(!expanded)}
        className="flex items-center gap-2 text-[13px] text-[#1264a3] dark:text-blue-400 hover:underline"
      >
        <svg className={`w-4 h-4 transition-transform ${expanded ? 'rotate-90' : ''}`} viewBox="0 0 16 16" fill="currentColor">
          <path d="M6 12l4-4-4-4" stroke="currentColor" strokeWidth="1.5" fill="none" strokeLinecap="round" strokeLinejoin="round"/>
        </svg>
        <span className="font-medium">{replies.length} {replies.length === 1 ? 'reply' : 'replies'}</span>
        {!expanded && lastReply && (
          <span className="text-zinc-500 dark:text-zinc-400">{lastReply.name}: {lastReply.text.slice(0, 30)}{lastReply.text.length > 30 ? '...' : ''}</span>
        )}
      </button>

      {expanded && (
        <div className="mt-2 ml-1 pl-3 border-l-2 border-zinc-200 dark:border-zinc-700 space-y-2">
          {replies.slice(0, visibleReplies).map((reply, i) => (
            <div key={i} className="flex items-start gap-2">
              <img src={reply.avatar} alt="" className="w-6 h-6 rounded-full flex-shrink-0" />
              <div>
                <span className="font-semibold text-[13px] text-[#1d1c1d] dark:text-zinc-100">{reply.name}</span>
                <span className="text-zinc-500 dark:text-zinc-400 text-[11px] ml-1.5">{reply.time}</span>
                <div className="text-[13px] text-[#1d1c1d] dark:text-zinc-300">{reply.text}</div>
              </div>
            </div>
          ))}
          {visibleReplies < replies.length && (
            <div className="flex items-center gap-2 text-zinc-400 text-[12px]">
              <div className="flex gap-0.5">
                <div className="w-1.5 h-1.5 bg-zinc-400 dark:bg-zinc-500 rounded-full animate-bounce" style={{ animationDelay: '0ms', animationDuration: '600ms' }}></div>
                <div className="w-1.5 h-1.5 bg-zinc-400 dark:bg-zinc-500 rounded-full animate-bounce" style={{ animationDelay: '150ms', animationDuration: '600ms' }}></div>
                <div className="w-1.5 h-1.5 bg-zinc-400 dark:bg-zinc-500 rounded-full animate-bounce" style={{ animationDelay: '300ms', animationDuration: '600ms' }}></div>
              </div>
            </div>
          )}
        </div>
      )}
    </div>
  )
}

// Reusable chat message component
const ChatMessage = ({ avatar, name, time, children, text, edited }) => (
  <div className="flex items-start gap-3">
    <img src={avatar} alt="" className="w-10 h-10 rounded-full flex-shrink-0" />
    <div className="flex-1">
      <div className="flex items-baseline gap-2">
        <span className="font-semibold text-[#1d1c1d] dark:text-zinc-100 text-[15px] tracking-[-0.01em]">{name}</span>
        {time && <span className="text-[#616061] dark:text-zinc-500 text-[12px]">{time}</span>}
        {edited && <span className="text-[#616061] dark:text-zinc-500 text-[11px]">(edited)</span>}
      </div>
      {text ? (
        <MessageText className="mt-0.5">{text}</MessageText>
      ) : (
        children
      )}
    </div>
  </div>
)

// Typing indicator component
const TypingIndicator = ({ avatar, name }) => (
  <div className="flex items-start gap-3">
    <img src={avatar} alt="" className="w-10 h-10 rounded-full flex-shrink-0" />
    <div className="flex-1">
      <div className="flex items-baseline gap-2">
        <span className="font-semibold text-[#1d1c1d] dark:text-zinc-100 text-[15px] tracking-[-0.01em]">{name}</span>
      </div>
      <div className="flex items-center gap-1 mt-1">
        <div className="flex gap-0.5">
          <div className="w-2 h-2 bg-zinc-400 dark:bg-zinc-500 rounded-full animate-bounce" style={{ animationDelay: '0ms', animationDuration: '600ms' }}></div>
          <div className="w-2 h-2 bg-zinc-400 dark:bg-zinc-500 rounded-full animate-bounce" style={{ animationDelay: '150ms', animationDuration: '600ms' }}></div>
          <div className="w-2 h-2 bg-zinc-400 dark:bg-zinc-500 rounded-full animate-bounce" style={{ animationDelay: '300ms', animationDuration: '600ms' }}></div>
        </div>
      </div>
    </div>
  </div>
)

// Slack incident thread conversation
export const SlackThread = ({ category = 'networking', topic = 'dns', topicName, categories = [], onCategoryChange }) => {
  const codeRef = React.useRef(null)
  const [visibleMessages, setVisibleMessages] = React.useState(0)
  const [typingUser, setTypingUser] = React.useState({ avatar: '/jacob-square.jpg', name: 'pagerduty' })
  const [dropdownOpen, setDropdownOpen] = React.useState(false)

  // Message sequence: pagerduty alert -> maya's diagnosis -> daniel's observation -> maya's finding -> replicate question
  const messageSequence = [
    { typingDuration: 1200 }, // pagerduty typing
    { delay: 500, avatar: '/profile-photo-3.jpg', name: 'maya', typingDuration: 1600 },
    { delay: 600, avatar: '/profile-photo-2.jpg', name: 'daniel', typingDuration: 1200 },
    { delay: 500, avatar: '/profile-photo-3.jpg', name: 'maya', typingDuration: 1400 },
    { delay: 600, avatar: '/logo.png', name: 'replicate.info', typingDuration: 700 },
    { delay: 0 },
  ]

  React.useEffect(() => {
    const seqIndex = visibleMessages
    if (seqIndex >= messageSequence.length) return

    const seq = messageSequence[seqIndex]

    // Show typing, then reveal message
    const messageTimeout = setTimeout(() => {
      setTypingUser(null)
      setVisibleMessages(v => v + 1)

      // Set next typing user after a delay
      const nextSeq = messageSequence[seqIndex + 1]
      if (nextSeq && nextSeq.avatar) {
        setTimeout(() => {
          setTypingUser({ avatar: nextSeq.avatar, name: nextSeq.name, isBot: nextSeq.isBot })
        }, nextSeq.delay || 0)
      }
    }, seq.typingDuration || 0)

    return () => clearTimeout(messageTimeout)
  }, [visibleMessages])

  React.useEffect(() => {
    if (codeRef.current && window.hljs && visibleMessages >= 2) {
      window.hljs.highlightElement(codeRef.current)
    }
  }, [visibleMessages])

  return (
    <div className="">
      <div className="rounded-lg overflow-hidden border border-zinc-300 dark:border-zinc-700 bg-white dark:bg-zinc-900 shadow-sm">
        {/* Window chrome */}
        <div className="bg-zinc-100 dark:bg-zinc-800 border-b border-zinc-200 dark:border-zinc-700 px-3 py-2 flex items-center relative">
          <div className="flex items-center gap-1.5">
            <div className="w-3 h-3 rounded-full bg-red-400 hover:bg-red-500 cursor-default transition-colors"></div>
            <div className="w-3 h-3 rounded-full bg-amber-400 hover:bg-amber-500 cursor-default transition-colors"></div>
            <div className="w-3 h-3 rounded-full bg-green-400 hover:bg-green-500 cursor-default transition-colors"></div>
          </div>
          <div className="absolute inset-0 flex items-center justify-center pointer-events-none">
            <span className="text-zinc-600 dark:text-zinc-400 text-xs font-semibold tracking-tight">#ops-alerts</span>
          </div>
        </div>

        {/* Messages */}
        <div className="divide-y divide-zinc-200 dark:divide-zinc-700 [&>*]:py-4 [&>*]:px-4">
          {/* Alert */}
          {visibleMessages >= 1 && (
            <ChatMessage
              avatar="/jacob-square.jpg"
              name="pagerduty"
              time="3:12 AM"
            >
              <div className="border-l-4 border-red-500 bg-[#f8f8f8] dark:bg-zinc-800 rounded-r px-3 py-2 mt-1">
                <div className="font-mono text-[13px] text-red-600 dark:text-red-400 mb-1">[SEV-1] DNS resolution failures across prod-east</div>
                <div className="text-[#1d1c1d] dark:text-zinc-100 text-sm font-medium">Services can't resolve internal hostnames — 503s spiking</div>
                <div className="text-[#616061] dark:text-zinc-400 text-xs mt-1">payments-api, orders-api, auth-service affected • 847 errors/min</div>
              </div>
              <div className="mt-2 flex gap-1">
                <EmojiReaction emoji="📌" count={1} />
                <EmojiReaction emoji="👀" count={5} />
              </div>
            </ChatMessage>
          )}

          {/* Maya's diagnosis */}
          {visibleMessages >= 2 && (
            <ChatMessage avatar="/profile-photo-3.jpg" name="maya" time="3:14 AM">
              <MessageText className="mt-0.5 mb-2">CoreDNS pods are OOMKilled — check the <Code>ndots</Code> setting in <Code>resolv.conf</Code></MessageText>
              <pre className="rounded-md text-[13px] leading-[1.5] overflow-x-auto !p-0"><code ref={codeRef} className="language-yaml !p-4 block">{`# /etc/resolv.conf in affected pods
nameserver 10.96.0.10
search default.svc.cluster.local svc.cluster.local cluster.local
options ndots:5  # <- every lookup tries 5 suffixes first`}</code></pre>
              <Thread replies={[
                { avatar: '/profile-photo-1.jpg', name: 'alex', time: '3:14 AM', text: 'wait so payments-api.prod hits the DNS server 6 times?' },
                { avatar: '/profile-photo-3.jpg', name: 'maya', time: '3:15 AM', text: 'yep — it tries all the search domains before going external' },
                { avatar: '/profile-photo-1.jpg', name: 'alex', time: '3:15 AM', text: 'thats insane, no wonder coredns is dying 😬' },
              ]} />
            </ChatMessage>
          )}

          {/* Daniel's observation */}
          {visibleMessages >= 3 && (
            <ChatMessage avatar="/profile-photo-2.jpg" name="daniel" time="3:16 AM">
              <MessageText className="mt-0.5 mb-2">found it — someone deployed a new sidecar that does <Code>nslookup</Code> every 100ms for health checks</MessageText>
              <MessageText className="text-zinc-500 dark:text-zinc-400 text-[13px] mb-2">this was in yesterday's deploy:</MessageText>
              <Diff
                filename="k8s/deployments/payments-api.yaml"
                additions={4}
                deletions={0}
                lines={[
                  { type: 'context', text: 'containers:' },
                  { type: 'add', text: '- name: dns-health-checker' },
                  { type: 'add', text: '  image: busybox' },
                  { type: 'add', text: '  command: ["sh", "-c", "while true; do nslookup google.com; sleep 0.1; done"]' },
                ]}
              />
              <div className="mt-2 flex gap-1">
                <EmojiReaction emoji="💀" count={3} />
                <EmojiReaction emoji="🤦" count={2} />
              </div>
              <Thread replies={[
                { avatar: '/profile-photo-1.jpg', name: 'sarah', time: '3:16 AM', text: 'that was me... thought it would catch DNS outages early 😅' },
                { avatar: '/profile-photo-2.jpg', name: 'daniel', time: '3:17 AM', text: '200 pods × 10 queries/sec = 2000 DNS queries/sec' },
                { avatar: '/profile-photo-1.jpg', name: 'sarah', time: '3:17 AM', text: 'oh god' },
                { avatar: '/profile-photo-3.jpg', name: 'maya', time: '3:17 AM', text: 'CoreDNS default is 1000 qps per instance lol' },
                { avatar: '/profile-photo-2.jpg', name: 'daniel', time: '3:18 AM', text: 'we have 2 replicas so you literally doubled our max capacity' },
                { avatar: '/profile-photo-1.jpg', name: 'sarah', time: '3:18 AM', text: 'rolling back now 🏃‍♀️' },
                { avatar: '/profile-photo-3.jpg', name: 'maya', time: '3:18 AM', text: '🙏' },
              ]} />
            </ChatMessage>
          )}

          {/* Maya's finding */}
          {visibleMessages >= 4 && (
            <ChatMessage avatar="/profile-photo-3.jpg" name="maya" time="3:19 AM" edited>
              <MessageText className="mt-0.5">rollback is out — DNS queries dropping back to normal. <Mention>@oncall</Mention> let's add CoreDNS autoscaling before this happens again</MessageText>
            </ChatMessage>
          )}

          {/* replicate.info prompt with multiple choice */}
          {visibleMessages >= 5 && (
            <div className="flex items-start gap-3">
              <img src="/logo.png" alt="" className="w-10 h-10 rounded-full flex-shrink-0" />
              <div className="flex-1">
                <div className="flex items-baseline justify-between gap-2">
                  <span className="font-semibold text-[#1d1c1d] dark:text-zinc-100 text-[15px] tracking-[-0.01em]">replicate.info</span>
                  <button className="px-3 py-1 text-[12px] font-medium text-white bg-indigo-600 hover:bg-indigo-700 rounded-full transition-colors">
                    Give me a hint
                  </button>
                </div>
                <MessageText className="mt-0.5 mb-3">What's the core issue with this DNS health check pattern?</MessageText>
                <div className="flex flex-col bg-gray-50 dark:bg-zinc-800 border border-gray-200 dark:border-zinc-700 shadow-sm rounded-lg overflow-hidden">
                  <label className="text-[15px] flex items-center p-[12px] cursor-pointer hover:bg-indigo-50 dark:hover:bg-indigo-900/30 border-b border-gray-200 dark:border-zinc-700">
                    <input type="radio" name="mc_dns" className="h-4 w-4 text-indigo-600 border-gray-400 focus:ring-indigo-500" />
                    <span className="ml-2">High-frequency polling overwhelms shared infrastructure like CoreDNS</span>
                  </label>
                  <label className="text-[15px] flex items-center p-[12px] cursor-pointer hover:bg-indigo-50 dark:hover:bg-indigo-900/30 border-b border-gray-200 dark:border-zinc-700">
                    <input type="radio" name="mc_dns" className="h-4 w-4 text-indigo-600 border-gray-400 focus:ring-indigo-500" />
                    <span className="ml-2">External DNS lookups should use a caching resolver</span>
                  </label>
                  <label className="text-[15px] flex items-center p-[12px] cursor-pointer hover:bg-indigo-50 dark:hover:bg-indigo-900/30">
                    <input type="radio" name="mc_dns" className="h-4 w-4 text-indigo-600 border-gray-400 focus:ring-indigo-500" />
                    <span className="ml-2">The ndots:5 setting amplifies every query into multiple requests</span>
                  </label>
                </div>
              </div>
            </div>
          )}

          {/* Typing indicator */}
          {typingUser && <TypingIndicator avatar={typingUser.avatar} name={typingUser.name} />}
        </div>

        {/* Chat input */}
        <div className="border-t border-zinc-200 dark:border-zinc-700 flex items-center">
          <input
            type="text"
            placeholder="Say something..."
            className="flex-1 px-4 py-3 text-[15px] text-[#1d1c1d] dark:text-zinc-200 placeholder-[#868686] dark:placeholder-zinc-500 outline-none border-none bg-transparent ring-0 focus:ring-0 focus:outline-none"
          />
          <div className="relative mr-3">
            <button
              onClick={() => setDropdownOpen(!dropdownOpen)}
              className="flex items-center gap-1.5 px-3 py-1.5 text-[13px] font-medium text-zinc-600 dark:text-zinc-300 bg-zinc-100 dark:bg-zinc-800 hover:bg-zinc-200 dark:hover:bg-zinc-700 rounded transition-colors"
            >
              {category}
              <svg className={`w-3.5 h-3.5 transition-transform ${dropdownOpen ? 'rotate-180' : ''}`} viewBox="0 0 16 16" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <path d="M4 6l4 4 4-4" />
              </svg>
            </button>
            {dropdownOpen && (
              <div className="absolute bottom-full right-0 mb-1 w-40 bg-white dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 rounded-lg shadow-lg overflow-hidden z-10">
                {categories.map(cat => (
                  <button
                    key={cat.name}
                    onClick={() => {
                      setDropdownOpen(false)
                      if (onCategoryChange) onCategoryChange(cat.name.toLowerCase())
                    }}
                    className={`w-full text-left px-3 py-2 text-[13px] hover:bg-zinc-100 dark:hover:bg-zinc-700 transition-colors ${
                      cat.name.toLowerCase() === category 
                        ? 'text-white font-medium' 
                        : 'text-zinc-600 dark:text-zinc-300'
                    }`}
                    style={cat.name.toLowerCase() === category ? { backgroundColor: '#1a365d' } : {}}
                  >
                    {cat.name.toLowerCase()}
                  </button>
                ))}
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}

// Git diff widget showing a problematic code change
export const GitDiff = () => {
  return (
    <div className="py-4">
      <div className="rounded-lg overflow-hidden border border-zinc-300 dark:border-zinc-700 bg-white dark:bg-zinc-900 shadow-sm">
        {/* Header */}
        <div className="bg-zinc-100 dark:bg-zinc-800 border-b border-zinc-200 dark:border-zinc-700 px-4 py-2 flex items-center justify-between">
          <div className="flex items-center gap-2">
            <svg className="w-4 h-4 text-zinc-500" viewBox="0 0 16 16" fill="currentColor">
              <path fillRule="evenodd" d="M8.75 1.75a.75.75 0 00-1.5 0V5H4a.75.75 0 000 1.5h3.25v3.25a.75.75 0 001.5 0V6.5H12A.75.75 0 0012 5H8.75V1.75zM4 13a.75.75 0 000 1.5h8a.75.75 0 000-1.5H4z" />
            </svg>
            <span className="font-mono text-sm text-zinc-700 dark:text-zinc-300">internal/handler/orders.go</span>
          </div>
          <div className="flex items-center gap-3 text-xs">
            <span className="text-green-600 dark:text-green-400">+12</span>
            <span className="text-red-500 dark:text-red-400">-8</span>
          </div>
        </div>

        {/* Diff content */}
        <div className="font-mono text-[13px] leading-[1.6] overflow-x-auto">
          {/* Context lines */}
          <div className="flex">
            <div className="w-10 text-right pr-2 text-zinc-400 dark:text-zinc-600 bg-zinc-50 dark:bg-zinc-800/50 select-none border-r border-zinc-200 dark:border-zinc-700">47</div>
            <div className="w-10 text-right pr-2 text-zinc-400 dark:text-zinc-600 bg-zinc-50 dark:bg-zinc-800/50 select-none border-r border-zinc-200 dark:border-zinc-700">47</div>
            <pre className="flex-1 px-3 text-zinc-600 dark:text-zinc-400"><code>{`func (h *OrderHandler) GetOrder(w http.ResponseWriter, r *http.Request) {`}</code></pre>
          </div>
          <div className="flex">
            <div className="w-10 text-right pr-2 text-zinc-400 dark:text-zinc-600 bg-zinc-50 dark:bg-zinc-800/50 select-none border-r border-zinc-200 dark:border-zinc-700">48</div>
            <div className="w-10 text-right pr-2 text-zinc-400 dark:text-zinc-600 bg-zinc-50 dark:bg-zinc-800/50 select-none border-r border-zinc-200 dark:border-zinc-700">48</div>
            <pre className="flex-1 px-3 text-zinc-600 dark:text-zinc-400"><code>{`    orderID := chi.URLParam(r, "id")`}</code></pre>
          </div>
          <div className="flex">
            <div className="w-10 text-right pr-2 text-zinc-400 dark:text-zinc-600 bg-zinc-50 dark:bg-zinc-800/50 select-none border-r border-zinc-200 dark:border-zinc-700">49</div>
            <div className="w-10 text-right pr-2 text-zinc-400 dark:text-zinc-600 bg-zinc-50 dark:bg-zinc-800/50 select-none border-r border-zinc-200 dark:border-zinc-700">49</div>
            <pre className="flex-1 px-3 text-zinc-600 dark:text-zinc-400"><code></code></pre>
          </div>

          {/* Removed lines */}
          <div className="flex bg-red-50 dark:bg-red-950/30">
            <div className="w-10 text-right pr-2 text-red-400 dark:text-red-500 bg-red-100 dark:bg-red-900/40 select-none border-r border-red-200 dark:border-red-800">50</div>
            <div className="w-10 text-right pr-2 text-red-400 dark:text-red-500 bg-red-100 dark:bg-red-900/40 select-none border-r border-red-200 dark:border-red-800"></div>
            <pre className="flex-1 px-3 text-red-700 dark:text-red-300"><code>{`-   order, err := h.store.GetByID(r.Context(), orderID)`}</code></pre>
          </div>
          <div className="flex bg-red-50 dark:bg-red-950/30">
            <div className="w-10 text-right pr-2 text-red-400 dark:text-red-500 bg-red-100 dark:bg-red-900/40 select-none border-r border-red-200 dark:border-red-800">51</div>
            <div className="w-10 text-right pr-2 text-red-400 dark:text-red-500 bg-red-100 dark:bg-red-900/40 select-none border-r border-red-200 dark:border-red-800"></div>
            <pre className="flex-1 px-3 text-red-700 dark:text-red-300"><code>{`-   if err != nil {`}</code></pre>
          </div>
          <div className="flex bg-red-50 dark:bg-red-950/30">
            <div className="w-10 text-right pr-2 text-red-400 dark:text-red-500 bg-red-100 dark:bg-red-900/40 select-none border-r border-red-200 dark:border-red-800">52</div>
            <div className="w-10 text-right pr-2 text-red-400 dark:text-red-500 bg-red-100 dark:bg-red-900/40 select-none border-r border-red-200 dark:border-red-800"></div>
            <pre className="flex-1 px-3 text-red-700 dark:text-red-300"><code>{`-       http.Error(w, "order not found", http.StatusNotFound)`}</code></pre>
          </div>
          <div className="flex bg-red-50 dark:bg-red-950/30">
            <div className="w-10 text-right pr-2 text-red-400 dark:text-red-500 bg-red-100 dark:bg-red-900/40 select-none border-r border-red-200 dark:border-red-800">53</div>
            <div className="w-10 text-right pr-2 text-red-400 dark:text-red-500 bg-red-100 dark:bg-red-900/40 select-none border-r border-red-200 dark:border-red-800"></div>
            <pre className="flex-1 px-3 text-red-700 dark:text-red-300"><code>{`-       return`}</code></pre>
          </div>
          <div className="flex bg-red-50 dark:bg-red-950/30">
            <div className="w-10 text-right pr-2 text-red-400 dark:text-red-500 bg-red-100 dark:bg-red-900/40 select-none border-r border-red-200 dark:border-red-800">54</div>
            <div className="w-10 text-right pr-2 text-red-400 dark:text-red-500 bg-red-100 dark:bg-red-900/40 select-none border-r border-red-200 dark:border-red-800"></div>
            <pre className="flex-1 px-3 text-red-700 dark:text-red-300"><code>{`-   }`}</code></pre>
          </div>

          {/* Added lines - the buggy change */}
          <div className="flex bg-green-50 dark:bg-green-950/30">
            <div className="w-10 text-right pr-2 text-green-500 dark:text-green-500 bg-green-100 dark:bg-green-900/40 select-none border-r border-green-200 dark:border-green-800"></div>
            <div className="w-10 text-right pr-2 text-green-500 dark:text-green-500 bg-green-100 dark:bg-green-900/40 select-none border-r border-green-200 dark:border-green-800">50</div>
            <pre className="flex-1 px-3 text-green-700 dark:text-green-300"><code>{`+   order, _ := h.store.GetByID(r.Context(), orderID)`}</code></pre>
          </div>

          {/* Context lines after */}
          <div className="flex">
            <div className="w-10 text-right pr-2 text-zinc-400 dark:text-zinc-600 bg-zinc-50 dark:bg-zinc-800/50 select-none border-r border-zinc-200 dark:border-zinc-700">55</div>
            <div className="w-10 text-right pr-2 text-zinc-400 dark:text-zinc-600 bg-zinc-50 dark:bg-zinc-800/50 select-none border-r border-zinc-200 dark:border-zinc-700">51</div>
            <pre className="flex-1 px-3 text-zinc-600 dark:text-zinc-400"><code></code></pre>
          </div>
          <div className="flex">
            <div className="w-10 text-right pr-2 text-zinc-400 dark:text-zinc-600 bg-zinc-50 dark:bg-zinc-800/50 select-none border-r border-zinc-200 dark:border-zinc-700">56</div>
            <div className="w-10 text-right pr-2 text-zinc-400 dark:text-zinc-600 bg-zinc-50 dark:bg-zinc-800/50 select-none border-r border-zinc-200 dark:border-zinc-800">52</div>
            <pre className="flex-1 px-3 text-zinc-600 dark:text-zinc-400"><code>{`    json.NewEncoder(w).Encode(order)  // panic: nil pointer`}</code></pre>
          </div>
          <div className="flex">
            <div className="w-10 text-right pr-2 text-zinc-400 dark:text-zinc-600 bg-zinc-50 dark:bg-zinc-800/50 select-none border-r border-zinc-200 dark:border-zinc-700">57</div>
            <div className="w-10 text-right pr-2 text-zinc-400 dark:text-zinc-600 bg-zinc-50 dark:bg-zinc-800/50 select-none border-r border-zinc-200 dark:border-zinc-700">53</div>
            <pre className="flex-1 px-3 text-zinc-600 dark:text-zinc-400"><code>{`}`}</code></pre>
          </div>
        </div>

        {/* Footer with commit info */}
        <div className="bg-zinc-50 dark:bg-zinc-800/50 border-t border-zinc-200 dark:border-zinc-700 px-4 py-2 flex items-center justify-between text-xs">
          <div className="flex items-center gap-2 text-zinc-500 dark:text-zinc-400">
            <img src="/profile-photo-2.jpg" alt="" className="w-5 h-5 rounded-full" />
            <span>daniel</span>
            <span className="text-zinc-400 dark:text-zinc-600">•</span>
            <span className="font-mono">a]1b7f2e</span>
            <span className="text-zinc-400 dark:text-zinc-600">•</span>
            <span>fix: skip db validation for perf</span>
          </div>
          <span className="text-zinc-400 dark:text-zinc-500">2 hours ago</span>
        </div>
      </div>
    </div>
  )
}


// Export all polished widgets
export const INCIDENT_WIDGETS = [
  SlackThread,
  MonitorAlert,
  PagerDutyAlert,
  GitDiff,
]

export default INCIDENT_WIDGETS