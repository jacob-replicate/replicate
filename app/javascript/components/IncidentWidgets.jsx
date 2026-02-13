import React from 'react'

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

// Slack incident thread conversation
export const SlackThread = () => {
  return (
    <div className="py-4">
      <div className="rounded-lg overflow-hidden border border-zinc-200 bg-white shadow-sm">
        {/* Window chrome */}
        <div className="bg-zinc-100 border-b border-zinc-200 px-3 py-2 flex items-center gap-2">
          <div className="flex items-center gap-1.5">
            <div className="w-3 h-3 rounded-full bg-red-400 hover:bg-red-500 cursor-default transition-colors"></div>
            <div className="w-3 h-3 rounded-full bg-amber-400 hover:bg-amber-500 cursor-default transition-colors"></div>
            <div className="w-3 h-3 rounded-full bg-green-400 hover:bg-green-500 cursor-default transition-colors"></div>
          </div>
          <div className="flex-1 flex items-center justify-center">
            <span className="text-zinc-500 text-xs font-medium tracking-tight">#ops-alerts</span>
          </div>
          <div className="w-[52px]"></div>
        </div>

        {/* Messages */}
        <div className="px-4 py-4 space-y-5">
          {/* Message 1 - Alert */}
          <div className="flex gap-3">
            <div className="w-10 h-10 rounded flex-shrink-0 bg-gradient-to-br from-blue-500 to-indigo-600 flex items-center justify-center">
              <span className="text-white text-lg">☸</span>
            </div>
            <div className="flex-1">
              <div className="flex items-baseline gap-2">
                <span className="font-semibold text-zinc-900 text-[15px] tracking-tight">k8s-alerts</span>
                <span className="text-zinc-400 text-xs">2:47 AM</span>
              </div>
              <div className="border-l-4 border-red-500 bg-zinc-50 rounded-r px-3 py-2 mt-1">
                <div className="font-mono text-sm text-red-600 mb-1">[OOMKilled] checkout-worker-6f8b9 restarting</div>
                <div className="text-zinc-800 text-sm font-medium">Container exceeded memory limit during GC pause</div>
                <div className="text-zinc-500 text-xs mt-1">3rd restart in 10min • node memory pressure detected</div>
              </div>
              {/* Reaction */}
              <div className="mt-1.5 flex items-center gap-1">
                <div className="flex items-center gap-1 px-1.5 py-0.5 rounded-full bg-zinc-100 border border-zinc-200">
                  <span className="text-xs">📌</span>
                  <span className="text-xs text-zinc-600 font-medium">1</span>
                </div>
              </div>
            </div>
          </div>

          {/* Message 2 */}
          <div className="flex gap-3">
            <img src="/profile-photo-3.jpg" alt="" className="w-10 h-10 rounded flex-shrink-0" />
            <div>
              <div className="flex items-baseline gap-2">
                <span className="font-semibold text-zinc-900 text-[15px] tracking-tight">maya</span>
                <span className="text-zinc-400 text-xs">2:48 AM</span>
              </div>
              <div className="text-zinc-800 text-[15px] mt-0.5">on it, pulling metrics</div>
            </div>
          </div>

          {/* Message 3 - with code */}
          <div className="flex gap-3">
            <img src="/profile-photo-3.jpg" alt="" className="w-10 h-10 rounded flex-shrink-0" />
            <div className="flex-1">
              <div className="flex items-baseline gap-2">
                <span className="font-semibold text-zinc-900 text-[15px] tracking-tight">maya</span>
                <span className="text-zinc-400 text-xs">2:49 AM</span>
              </div>
              <div className="text-zinc-800 text-[15px] mt-0.5 mb-2">here's what I'm seeing:</div>
              <div className="bg-zinc-900 rounded font-mono text-[13px] p-3 leading-6">
                <div className="text-zinc-300"><span className="text-zinc-500">$</span> kubectl top pod checkout-worker-6f8b9</div>
                <div className="text-zinc-500 mt-2">NAME                    CPU   MEM</div>
                <div className="text-zinc-300">checkout-worker-6f8b9   340m  <span className="text-red-400">1998Mi/2Gi</span></div>
                <div className="text-zinc-600 mt-3">memory.high breached — reclaim stalled 847ms</div>
                <div className="text-amber-400">pressure avg10=<span className="text-red-400">78.42</span> avg60=52.18</div>
              </div>
            </div>
          </div>

          {/* Message 4 */}
          <div className="flex gap-3">
            <img src="/profile-photo-2.jpg" alt="" className="w-10 h-10 rounded flex-shrink-0" />
            <div className="flex-1">
              <div className="flex items-baseline gap-2">
                <span className="font-semibold text-zinc-900 text-[15px] tracking-tight">daniel</span>
                <span className="text-zinc-400 text-xs">2:51 AM</span>
              </div>
              <div className="text-zinc-800 text-[15px] mt-0.5">wait — if heap is only at 1998Mi, why is pressure that high? that doesn't add up</div>
            </div>
          </div>

          {/* Message 5 */}
          <div className="flex gap-3">
            <img src="/profile-photo-3.jpg" alt="" className="w-10 h-10 rounded flex-shrink-0" />
            <div>
              <div className="flex items-baseline gap-2">
                <span className="font-semibold text-zinc-900 text-[15px]">maya</span>
                <span className="text-zinc-400 text-xs">2:52 AM</span>
              </div>
              <div className="text-zinc-800 text-[15px] mt-0.5"><span className="text-blue-600 bg-blue-50 rounded px-0.5">@daniel</span> good catch. let me check what else is in that cgroup...</div>
            </div>
          </div>

          {/* Message 6 - the hook */}
          <div className="flex gap-3">
            <img src="/profile-photo-2.jpg" alt="" className="w-10 h-10 rounded flex-shrink-0" />
            <div className="flex-1">
              <div className="flex items-baseline gap-2">
                <span className="font-semibold text-zinc-900 text-[15px]">daniel</span>
                <span className="text-zinc-400 text-xs">2:52 AM</span>
              </div>
              <div className="text-zinc-800 text-[15px] mt-0.5">also — is this the JVM heap or the container limit? those are different numbers</div>
            </div>
          </div>

          {/* replicate.info prompt */}
          <div className="flex gap-3">
            <img src="/logo.png" alt="" className="w-10 h-10 rounded flex-shrink-0" />
            <div className="flex-1">
              <div className="flex items-baseline gap-2">
                <span className="font-semibold text-zinc-900 text-[15px]">replicate.info</span>
              </div>
              <div className="text-zinc-800 text-[15px] mt-0.5">
                Why might memory pressure spike even when heap usage looks fine?
              </div>
            </div>
          </div>

          {/* Multiple choice options */}
          <div className="mt-2 mb-2">
            <div className="flex flex-col bg-gray-50 border border-gray-200 shadow-sm rounded-lg overflow-hidden">
              <label className="text-[15px] flex items-center p-[12px] cursor-pointer hover:bg-indigo-50 border-b border-gray-200">
                <input type="radio" name="mc_memory" className="h-4 w-4 text-indigo-600 border-gray-400 focus:ring-indigo-500" />
                <span className="ml-2">The JVM is allocating off-heap memory that doesn't show up in heap metrics</span>
              </label>
              <label className="text-[15px] flex items-center p-[12px] cursor-pointer hover:bg-indigo-50 border-b border-gray-200">
                <input type="radio" name="mc_memory" className="h-4 w-4 text-indigo-600 border-gray-400 focus:ring-indigo-500" />
                <span className="ml-2">The container limit is lower than the JVM's max heap setting</span>
              </label>
              <label className="text-[15px] flex items-center p-[12px] cursor-pointer hover:bg-indigo-50">
                <input type="radio" name="mc_memory" className="h-4 w-4 text-indigo-600 border-gray-400 focus:ring-indigo-500" />
                <span className="ml-2">Other processes in the cgroup are consuming memory alongside the JVM</span>
              </label>
            </div>
          </div>
        </div>

        {/* Chat input with hint link */}
        <div className="border-t border-zinc-100 flex items-center">
          <input
            type="text"
            placeholder="Say something..."
            className="flex-1 px-4 py-3 text-sm text-zinc-700 placeholder-zinc-400 outline-none border-none bg-transparent ring-0 focus:ring-0 focus:outline-none"
          />
          <div className="flex items-center gap-1.5 text-indigo-500 text-sm pr-4 cursor-pointer hover:text-indigo-600">
            <span>✨</span>
            <span className="font-medium">Give me a hint</span>
          </div>
        </div>
      </div>
    </div>
  )
}


// Export all polished widgets
export const INCIDENT_WIDGETS = [
  SlackThread,
  PagerDutyAlert,
  MonitorAlert,
]

export default INCIDENT_WIDGETS