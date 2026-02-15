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
export const Diff = ({ filename, lines }) => {
  // Calculate additions and deletions dynamically from lines
  const additions = lines.filter(line => line.type === 'add').length
  const deletions = lines.filter(line => line.type === 'remove').length

  return (
    <div className="rounded border border-zinc-200 dark:border-zinc-700 overflow-hidden text-[13px] font-mono">
      {filename && (
        <div className="bg-zinc-100 dark:bg-zinc-800 px-2 py-1 text-zinc-500 dark:text-zinc-400 border-b border-zinc-200 dark:border-zinc-700 flex items-center justify-between">
          <span>{filename}</span>
          {(additions > 0 || deletions > 0) && (
            <div className="flex items-center gap-2">
              {additions > 0 && <span className="text-green-600 dark:text-green-400">+{additions}</span>}
              {deletions > 0 && <span className="text-red-500 dark:text-red-400">-{deletions}</span>}
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
}

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

// Inline Monitor widget (Datadog-style) for embedding in chat
const Monitor = ({ title, metric, value, threshold, status = 'warning' }) => {
  const [dataPoints] = React.useState(() => {
    const initial = []
    for (let i = 0; i < 20; i++) {
      const progress = i / 19
      const base = 15 + progress * (value - 15)
      const noise = (Math.random() - 0.5) * 5
      initial.push(Math.max(0, Math.min(100, base + noise)))
    }
    return initial
  })

  const toY = (pct) => 40 - (pct / 100) * 40
  const points = dataPoints.map((val, i) => `${(i / 19) * 200},${toY(val)}`).join(' L')
  const linePath = `M${points}`
  const areaPath = `${linePath} L200,40 L0,40 Z`
  const lastY = toY(dataPoints[dataPoints.length - 1])

  const colors = status === 'critical'
    ? { bg: '#fef2f2', border: 'border-red-400', text: 'text-red-700', badge: 'bg-red-600', stroke: '#ef4444', fill: '#fee2e2' }
    : { bg: '#fffbeb', border: 'border-amber-300', text: 'text-amber-700', badge: 'bg-zinc-600', stroke: '#f59e0b', fill: '#fef3c7' }

  return (
    <div className={`rounded-lg overflow-hidden border-2 ${colors.border} mt-2`} style={{ backgroundColor: colors.bg }}>
      <div className="px-4 pt-3 pb-2 flex items-center justify-between">
        <div className="flex items-center gap-2">
          <svg className={`w-4 h-4 ${colors.text}`} viewBox="0 0 24 24" fill="currentColor">
            <rect x="3" y="4" width="18" height="4" rx="1" opacity="0.5" />
            <rect x="3" y="10" width="18" height="4" rx="1" opacity="0.7" />
            <rect x="3" y="16" width="18" height="4" rx="1" />
          </svg>
          <span className={`${colors.text} font-medium text-sm`}>Monitor Alert</span>
        </div>
        <span className={`px-2 py-1 rounded text-xs font-semibold ${colors.badge} text-white`}>
          {status === 'critical' ? 'Critical' : 'Warning'}
        </span>
      </div>
      <div className="px-4 pb-1">
        <h3 className="text-zinc-900 text-base font-semibold">{title}</h3>
        <div className={`flex items-center gap-2 ${colors.text} text-sm`}>
          <span>{metric}</span>
          <span className="opacity-50">•</span>
          <span>{value}% used</span>
        </div>
      </div>
      <div className="px-4 pb-3 pt-1">
        <div className="flex justify-end mb-1">
          <span className="text-[10px] text-red-400 font-medium">{threshold}%</span>
        </div>
        <div className="relative">
          <div className="absolute w-full border-t-2 border-dashed border-red-400/60" style={{ top: `${(1 - threshold/100) * 48}px` }} />
          <svg viewBox="0 0 200 40" className="w-full h-10" preserveAspectRatio="none">
            <defs>
              <linearGradient id={`grad-${title}`} x1="0" y1="0" x2="0" y2="1">
                <stop offset="0%" stopColor={colors.stroke} stopOpacity="0.4" />
                <stop offset="100%" stopColor={colors.stroke} stopOpacity="0.1" />
              </linearGradient>
            </defs>
            <path d={areaPath} fill={`url(#grad-${title})`} />
            <path d={linePath} fill="none" stroke={colors.stroke} strokeWidth="2" strokeLinecap="round" />
            <circle cx="200" cy={lastY} r="3" fill={colors.stroke}>
              <animate attributeName="r" values="3;5;3" dur="1s" repeatCount="indefinite" />
            </circle>
          </svg>
        </div>
      </div>
    </div>
  )
}

// Inline OncallAlert widget (PagerDuty-style) for embedding in chat
const OncallAlert = ({ severity = 'SEV-1', service, alert, error, affected, commit }) => {
  const severityColors = {
    'SEV-1': { bg: 'bg-red-500/20', text: 'text-red-400', border: 'border-red-500/30' },
    'SEV-2': { bg: 'bg-orange-500/20', text: 'text-orange-400', border: 'border-orange-500/30' },
  }
  const colors = severityColors[severity] || severityColors['SEV-1']

  return (
    <div className="rounded-lg bg-zinc-800 border border-zinc-700 p-4 mt-2">
      <div className="flex items-center gap-3">
        <div className="w-2 h-2 rounded-full bg-red-500 animate-pulse flex-shrink-0" />
        <div className="flex-1">
          <div className="flex items-center gap-2 mb-1">
            <span className="text-white font-medium">{service}</span>
            <span className={`px-1.5 py-0.5 rounded text-xs font-bold ${colors.bg} ${colors.text} ${colors.border} border`}>{severity}</span>
          </div>
          <div className="text-zinc-400 text-sm mb-2">{alert}</div>
          <div className="flex items-center gap-3 text-xs flex-wrap">
            {error && <span className="font-mono text-red-400 bg-red-500/10 px-1.5 py-0.5 rounded">{error}</span>}
            {affected && <span className="text-zinc-400">{affected}</span>}
            {commit && <><span className="text-zinc-500">•</span><span className="text-zinc-400 font-mono">{commit}</span></>}
          </div>
        </div>
      </div>
    </div>
  )
}

// Slack incident thread conversation
export const SlackThread = ({ category = 'networking', topic = 'dns' }) => {
  const codeRef = React.useRef(null)
  const codeRef2 = React.useRef(null)
  const [visibleMessages, setVisibleMessages] = React.useState(0)
  const [typingUser, setTypingUser] = React.useState({ avatar: '/jacob-square.jpg', name: 'pagerduty' })

  const messageSequence = [
    { typingDuration: 1200 },
    { delay: 400, avatar: '/profile-photo-3.jpg', name: 'maya', typingDuration: 1400 },
    { delay: 300, avatar: '/profile-photo-2.jpg', name: 'daniel', typingDuration: 1600 },
    { delay: 500, avatar: '/profile-photo-1.jpg', name: 'alex', typingDuration: 1200 },
    { delay: 400, avatar: '/profile-photo-3.jpg', name: 'maya', typingDuration: 1800 },
    { delay: 300, avatar: '/profile-photo-2.jpg', name: 'daniel', typingDuration: 1400 },
    { delay: 500, avatar: '/profile-photo-3.jpg', name: 'maya', typingDuration: 1000 },
    { delay: 600, avatar: '/logo.png', name: 'invariant.training', typingDuration: 800 },
    { delay: 0 },
  ]

  React.useEffect(() => {
    const seqIndex = visibleMessages
    if (seqIndex >= messageSequence.length) return
    const seq = messageSequence[seqIndex]

    const messageTimeout = setTimeout(() => {
      setTypingUser(null)
      setVisibleMessages(v => v + 1)
      const nextSeq = messageSequence[seqIndex + 1]
      if (nextSeq && nextSeq.avatar) {
        setTimeout(() => {
          setTypingUser({ avatar: nextSeq.avatar, name: nextSeq.name })
        }, nextSeq.delay || 0)
      }
    }, seq.typingDuration || 0)

    return () => clearTimeout(messageTimeout)
  }, [visibleMessages])

  React.useEffect(() => {
    if (codeRef.current && window.hljs && visibleMessages >= 3) {
      window.hljs.highlightElement(codeRef.current)
    }
    if (codeRef2.current && window.hljs && visibleMessages >= 5) {
      window.hljs.highlightElement(codeRef2.current)
    }
  }, [visibleMessages])

  return (
    <div className="rounded-xl overflow-hidden shadow-sm border border-zinc-200/60 dark:border-zinc-700">
      <div className="bg-white dark:bg-zinc-900">
        {/* Window chrome */}
        <div className="bg-zinc-100 dark:bg-zinc-800 border-b border-zinc-200 dark:border-zinc-700 px-3 py-2 flex items-center relative">
          <div className="flex items-center gap-1.5">
            <div className="w-3 h-3 rounded-full bg-red-400 hover:bg-red-500 cursor-default transition-colors"></div>
            <div className="w-3 h-3 rounded-full bg-amber-400 hover:bg-amber-500 cursor-default transition-colors"></div>
            <div className="w-3 h-3 rounded-full bg-green-400 hover:bg-green-500 cursor-default transition-colors"></div>
          </div>
          <div className="absolute inset-0 flex items-center justify-center pointer-events-none">
            <span className="text-zinc-600 dark:text-zinc-400 text-xs font-semibold tracking-tight">#incident-2847</span>
          </div>
        </div>

        {/* Messages */}
        <div className="divide-y divide-zinc-200 dark:divide-zinc-700 [&>*]:py-4 [&>*]:px-4">

          {/* Message 1: PagerDuty Alert */}
          {visibleMessages >= 1 && (
            <ChatMessage avatar="/jacob-square.jpg" name="pagerduty" time="2:47 AM">
              <OncallAlert
                severity="SEV-1"
                service="orders-api"
                alert="Connection pool exhausted — all 50 connections in use"
                error="ECONNREFUSED"
                affected="~3,200 orders/min failing"
                commit="d4f8a2c"
              />
              <div className="mt-2 flex gap-1">
                <EmojiReaction emoji="🔥" count={4} />
                <EmojiReaction emoji="👀" count={7} />
              </div>
            </ChatMessage>
          )}

          {/* Message 2: Maya joins */}
          {visibleMessages >= 2 && (
            <ChatMessage avatar="/profile-photo-3.jpg" name="maya" time="2:48 AM">
              <MessageText className="mt-0.5">taking IC. <Mention>@daniel</Mention> can you pull up the connection metrics? seeing <Code>max_connections=50</Code> but we should have headroom</MessageText>
              <Monitor
                title="PostgreSQL Connection Pool"
                metric="orders-db-primary"
                value={98}
                threshold={90}
                status="critical"
              />
              <Thread replies={[
                { avatar: '/profile-photo-2.jpg', name: 'daniel', time: '2:48 AM', text: 'on it — pulling grafana now' },
                { avatar: '/profile-photo-1.jpg', name: 'alex', time: '2:49 AM', text: 'anything I can help with?' },
                { avatar: '/profile-photo-3.jpg', name: 'maya', time: '2:49 AM', text: 'alex check if this is isolated to orders or if payments is affected too' },
              ]} />
            </ChatMessage>
          )}

          {/* Message 3: Daniel finds something */}
          {visibleMessages >= 3 && (
            <ChatMessage avatar="/profile-photo-2.jpg" name="daniel" time="2:51 AM">
              <MessageText className="mt-0.5 mb-2">found it — connection acquire time spiking. looks like queries are hanging and never returning connections to the pool</MessageText>
              <pre className="rounded-md text-[13px] leading-[1.5] overflow-x-auto !p-0"><code ref={codeRef} className="language-sql !p-4 block">{`-- active connections by state
SELECT state, count(*), max(now() - query_start) as max_duration
FROM pg_stat_activity WHERE datname = 'orders'
GROUP BY state;

 state  | count |  max_duration
--------+-------+----------------
 active |    47 | 00:04:23.445   -- these should be milliseconds
 idle   |     3 | 00:00:01.234`}</code></pre>
              <div className="mt-2 flex gap-1">
                <EmojiReaction emoji="😱" count={3} />
              </div>
            </ChatMessage>
          )}

          {/* Message 4: Alex finds related issue */}
          {visibleMessages >= 4 && (
            <ChatMessage avatar="/profile-photo-1.jpg" name="alex" time="2:52 AM">
              <MessageText className="mt-0.5 mb-2">payments is fine, but I found something weird — someone added a new <Code>SELECT FOR UPDATE</Code> yesterday that's taking row locks</MessageText>
              <Diff
                filename="internal/orders/repository.go"
                lines={[
                  { type: 'context', text: 'func (r *Repository) GetOrderForProcessing(ctx context.Context, id string) (*Order, error) {' },
                  { type: 'remove', text: '    return r.db.GetOrder(ctx, id)' },
                  { type: 'add', text: '    // Lock row to prevent double-processing' },
                  { type: 'add', text: '    return r.db.QueryRow(ctx, `SELECT * FROM orders WHERE id = $1 FOR UPDATE`, id)' },
                  { type: 'context', text: '}' },
                ]}
              />
              <Thread replies={[
                { avatar: '/profile-photo-2.jpg', name: 'daniel', time: '2:53 AM', text: 'oh no... FOR UPDATE with no timeout will wait forever for the lock' },
                { avatar: '/profile-photo-1.jpg', name: 'alex', time: '2:53 AM', text: 'and if multiple workers try to process the same order...' },
                { avatar: '/profile-photo-2.jpg', name: 'daniel', time: '2:53 AM', text: 'deadlock city 💀' },
              ]} />
            </ChatMessage>
          )}

          {/* Message 5: Maya digs deeper */}
          {visibleMessages >= 5 && (
            <ChatMessage avatar="/profile-photo-3.jpg" name="maya" time="2:55 AM">
              <MessageText className="mt-0.5 mb-2">confirmed — we have 23 transactions waiting on each other. classic deadlock pattern</MessageText>
              <pre className="rounded-md text-[13px] leading-[1.5] overflow-x-auto !p-0"><code ref={codeRef2} className="language-sql !p-4 block">{`-- blocked queries waiting on locks
SELECT blocked.pid, blocked.query, blocking.pid as blocking_pid
FROM pg_stat_activity blocked
JOIN pg_locks bl ON bl.pid = blocked.pid
JOIN pg_locks l ON l.relation = bl.relation AND l.pid != bl.pid
JOIN pg_stat_activity blocking ON l.pid = blocking.pid
WHERE NOT bl.granted;

-- 23 rows returned, circular dependencies detected`}</code></pre>
              <Monitor
                title="Lock Wait Queue Depth"
                metric="orders-db-primary"
                value={87}
                threshold={80}
                status="critical"
              />
            </ChatMessage>
          )}

          {/* Message 6: Daniel proposes fix */}
          {visibleMessages >= 6 && (
            <ChatMessage avatar="/profile-photo-2.jpg" name="daniel" time="2:57 AM">
              <MessageText className="mt-0.5 mb-2">options: (1) kill the stuck queries and rollback, (2) add <Code>NOWAIT</Code> or <Code>SKIP LOCKED</Code> to the query, (3) revert the commit entirely</MessageText>
              <MessageText className="text-zinc-500 dark:text-zinc-400 text-[13px]">I'd vote revert — the <Code>FOR UPDATE</Code> approach needs a proper queue, not row locking</MessageText>
              <div className="mt-2 flex gap-1">
                <EmojiReaction emoji="👍" count={2} />
                <EmojiReaction emoji="💯" count={1} />
              </div>
              <Thread replies={[
                { avatar: '/profile-photo-1.jpg', name: 'alex', time: '2:57 AM', text: 'agreed — I can have the revert ready in 2 min' },
                { avatar: '/profile-photo-3.jpg', name: 'maya', time: '2:58 AM', text: 'do it. daniel can you kill the stuck connections so we recover faster?' },
                { avatar: '/profile-photo-2.jpg', name: 'daniel', time: '2:58 AM', text: 'already on it' },
              ]} />
            </ChatMessage>
          )}

          {/* Message 7: Maya confirms resolution */}
          {visibleMessages >= 7 && (
            <ChatMessage avatar="/profile-photo-3.jpg" name="maya" time="3:04 AM" edited>
              <MessageText className="mt-0.5">revert is deployed, killed 23 stuck connections. pool is recovering — down to 12 active connections now. <Mention>@oncall</Mention> marking resolved but we need a proper fix for the double-processing issue</MessageText>
              <div className="mt-2 flex gap-1">
                <EmojiReaction emoji="🎉" count={4} />
                <EmojiReaction emoji="🙏" count={2} />
              </div>
            </ChatMessage>
          )}

          {/* Message 8: invariant.training narrator question */}
          {visibleMessages >= 8 && (
            <div className="flex items-start gap-3">
              <img src="/logo.png" alt="" className="w-10 h-10 rounded-full flex-shrink-0" />
              <div className="flex-1">
                <div className="flex items-baseline justify-between gap-2">
                  <span className="font-semibold text-[#1d1c1d] dark:text-zinc-100 text-[15px] tracking-[-0.01em]">invariant.training</span>
                  <span className="text-[#616061] dark:text-zinc-500 text-[12px]">3:05 AM</span>
                </div>
                <MessageText className="mt-0.5 mb-3">The team reverted the change, but the underlying problem remains: orders can still be double-processed. What's the right architectural fix?</MessageText>
                <div className="flex flex-col bg-gray-50 dark:bg-zinc-800/60 border border-gray-200 dark:border-zinc-600 shadow-sm rounded-lg overflow-hidden">
                  <label className="text-[15px] flex items-center p-[12px] cursor-pointer hover:bg-indigo-50 dark:hover:bg-indigo-900/40 border-b border-gray-200 dark:border-zinc-600">
                    <input type="radio" name="mc_pool" className="h-4 w-4 text-indigo-600 border-gray-400 dark:border-zinc-500 focus:ring-indigo-500 dark:bg-zinc-700" />
                    <span className="ml-3 text-zinc-800 dark:text-zinc-200">Use SELECT FOR UPDATE SKIP LOCKED to avoid blocking</span>
                  </label>
                  <label className="text-[15px] flex items-center p-[12px] cursor-pointer hover:bg-indigo-50 dark:hover:bg-indigo-900/40 border-b border-gray-200 dark:border-zinc-600">
                    <input type="radio" name="mc_pool" className="h-4 w-4 text-indigo-600 border-gray-400 dark:border-zinc-500 focus:ring-indigo-500 dark:bg-zinc-700" />
                    <span className="ml-3 text-zinc-800 dark:text-zinc-200">Add a distributed lock service like Redis or Zookeeper</span>
                  </label>
                  <label className="text-[15px] flex items-center p-[12px] cursor-pointer hover:bg-indigo-50 dark:hover:bg-indigo-900/40 border-b border-gray-200 dark:border-zinc-600">
                    <input type="radio" name="mc_pool" className="h-4 w-4 text-indigo-600 border-gray-400 dark:border-zinc-500 focus:ring-indigo-500 dark:bg-zinc-700" />
                    <span className="ml-3 text-zinc-800 dark:text-zinc-200">Use a proper job queue with exactly-once delivery guarantees</span>
                  </label>
                  <label className="text-[15px] flex items-center p-[12px] cursor-pointer hover:bg-indigo-50 dark:hover:bg-indigo-900/40">
                    <input type="radio" name="mc_pool" className="h-4 w-4 text-indigo-600 border-gray-400 dark:border-zinc-500 focus:ring-indigo-500 dark:bg-zinc-700" />
                    <span className="ml-3 text-zinc-800 dark:text-zinc-200">Increase the connection pool size to handle lock contention</span>
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
  MonitorAlert,
  PagerDutyAlert,
]

export default INCIDENT_WIDGETS