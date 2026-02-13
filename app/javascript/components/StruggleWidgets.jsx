import React from 'react'

// Live incident scenarios - designed to feel like real alerts happening NOW
const LIVE_INCIDENTS = [
  {
    channel: '#incidents',
    service: 'payments-api',
    alert: 'POST /payments returning 500s',
    metric: '47% error rate',
    time: '3 min ago',
    slug: 'transactions',
    oncall: 'You',
  },
  {
    channel: '#prod-alerts',
    service: 'user-service',
    alert: 'Connection pool exhausted',
    metric: '0 available connections',
    time: '1 min ago',
    slug: 'resource-limits',
    oncall: 'You',
  },
  {
    channel: '#incidents',
    service: 'search-cluster',
    alert: 'Node election in progress',
    metric: '2/5 nodes unreachable',
    time: '45 sec ago',
    slug: 'consensus',
    oncall: 'You',
  },
  {
    channel: '#database-alerts',
    service: 'postgres-primary',
    alert: 'Replication lag critical',
    metric: '847s behind',
    time: '2 min ago',
    slug: 'stale-reads',
    oncall: 'You',
  },
  {
    channel: '#prod-alerts',
    service: 'api-gateway',
    alert: 'Upstream timeout errors',
    metric: 'p99 latency 12.4s',
    time: '5 min ago',
    slug: 'load-balancing',
    oncall: 'You',
  },
  {
    channel: '#incidents',
    service: 'cache-layer',
    alert: 'Redis cluster split-brain detected',
    metric: '2 masters elected',
    time: '30 sec ago',
    slug: 'caching',
    oncall: 'You',
  },
  {
    channel: '#security-alerts',
    service: 'auth-service',
    alert: 'Unusual token generation spike',
    metric: '15x baseline',
    time: '8 min ago',
    slug: 'iam',
    oncall: 'You',
  },
  {
    channel: '#prod-alerts',
    service: 'orders-api',
    alert: 'Deadlock detected in transaction',
    metric: '12 queries waiting',
    time: '1 min ago',
    slug: 'transactions',
    oncall: 'You',
  },
  {
    channel: '#incidents',
    service: 'cdn-edge',
    alert: 'Cache hit ratio dropped',
    metric: '23% (was 94%)',
    time: '4 min ago',
    slug: 'caching',
    oncall: 'You',
  },
  {
    channel: '#database-alerts',
    service: 'mysql-replica',
    alert: 'Disk usage critical',
    metric: '97% full',
    time: '6 min ago',
    slug: 'backups',
    oncall: 'You',
  },
]

// Variation 1: Slack-style alert
export const StruggleWidget1 = () => {
  const incident = LIVE_INCIDENTS[0]
  return (
    <div className="py-4">
      <a
        href={`/topics/${incident.slug}`}
        className="block p-4 rounded-lg bg-[#1a1d21] hover:bg-[#222529] transition-colors group border border-zinc-800"
      >
        <div className="flex items-center gap-2 mb-2">
          <div className="w-5 h-5 rounded bg-red-500 flex items-center justify-center">
            <span className="text-white text-xs font-bold">!</span>
          </div>
          <span className="text-[#e8912d] font-semibold text-sm">{incident.channel}</span>
          <span className="text-zinc-500 text-xs">{incident.time}</span>
        </div>
        <div className="flex items-start gap-3">
          <div className="w-9 h-9 rounded bg-gradient-to-br from-red-500 to-orange-500 flex items-center justify-center text-white text-xs font-bold flex-shrink-0">PD</div>
          <div>
            <div className="text-white text-sm"><span className="font-semibold">PagerDuty</span> <span className="text-zinc-400">triggered an incident</span></div>
            <div className="mt-1 p-2 rounded bg-zinc-800/50 border-l-2 border-red-500">
              <div className="text-red-400 font-mono text-sm">[FIRING] {incident.service}</div>
              <div className="text-zinc-300 text-sm mt-1">{incident.alert}</div>
              <div className="text-zinc-500 text-xs mt-1">{incident.metric}</div>
            </div>
            <div className="mt-2 text-xs text-blue-400 group-hover:underline">Jump into this scenario →</div>
          </div>
        </div>
      </a>
    </div>
  )
}

// Variation 2: PagerDuty notification style
export const StruggleWidget2 = () => {
  const incident = LIVE_INCIDENTS[1]
  return (
    <div className="py-4">
      <a
        href={`/topics/${incident.slug}`}
        className="block p-4 rounded-lg bg-[#0b5e1e] hover:bg-[#0d6b22] transition-colors group"
      >
        <div className="flex items-center justify-between mb-2">
          <div className="flex items-center gap-2">
            <div className="w-2 h-2 rounded-full bg-red-500 animate-pulse"></div>
            <span className="text-white font-semibold text-sm">INCIDENT TRIGGERED</span>
          </div>
          <span className="text-green-200 text-xs font-mono">{incident.time}</span>
        </div>
        <div className="text-white font-mono text-lg mb-1">{incident.service}</div>
        <div className="text-green-100 text-sm mb-2">{incident.alert}</div>
        <div className="flex items-center justify-between">
          <div className="text-green-300 text-xs">Assigned to: <span className="font-semibold">{incident.oncall}</span></div>
          <div className="text-green-200 text-xs group-hover:underline">Respond to this →</div>
        </div>
      </a>
    </div>
  )
}

// Variation 3: Datadog/monitoring dashboard alert
export const StruggleWidget3 = () => {
  const incident = LIVE_INCIDENTS[2]
  return (
    <div className="py-4">
      <a
        href={`/topics/${incident.slug}`}
        className="block p-4 rounded-lg bg-[#632ca6] hover:bg-[#7235b8] transition-colors group"
      >
        <div className="flex items-center gap-2 mb-3">
          <svg className="w-5 h-5 text-white" viewBox="0 0 24 24" fill="currentColor">
            <path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"/>
          </svg>
          <span className="text-white font-semibold text-sm">Monitor Alert</span>
          <span className="ml-auto px-2 py-0.5 rounded text-xs font-bold bg-red-500 text-white">ALERT</span>
        </div>
        <div className="text-white text-lg font-semibold mb-1">{incident.alert}</div>
        <div className="flex items-center gap-4 text-purple-200 text-sm mb-3">
          <span className="font-mono">{incident.service}</span>
          <span>•</span>
          <span className="text-red-300 font-semibold">{incident.metric}</span>
        </div>
        <div className="h-8 bg-purple-900/50 rounded flex items-end px-1 gap-px mb-2">
          {[20,35,25,45,60,75,95,85,90,88,92,95].map((h, i) => (
            <div key={i} className="flex-1 bg-red-400 rounded-t" style={{height: `${h}%`}}></div>
          ))}
        </div>
        <div className="text-purple-200 text-xs group-hover:underline">Investigate this alert →</div>
      </a>
    </div>
  )
}

// Variation 4: Terminal/CLI style alert
export const StruggleWidget4 = () => {
  const incident = LIVE_INCIDENTS[3]
  return (
    <div className="py-4">
      <a
        href={`/topics/${incident.slug}`}
        className="block rounded-lg bg-black border border-zinc-800 overflow-hidden hover:border-zinc-600 transition-colors group"
      >
        <div className="px-3 py-1.5 bg-zinc-900 border-b border-zinc-800 flex items-center gap-2">
          <div className="flex gap-1.5">
            <div className="w-3 h-3 rounded-full bg-red-500"></div>
            <div className="w-3 h-3 rounded-full bg-yellow-500"></div>
            <div className="w-3 h-3 rounded-full bg-green-500"></div>
          </div>
          <span className="text-zinc-500 text-xs font-mono">alerts — zsh</span>
        </div>
        <div className="p-4 font-mono text-sm">
          <div className="text-zinc-500">$ tail -f /var/log/alerts.log</div>
          <div className="text-red-400 mt-2">[CRITICAL] {incident.time}</div>
          <div className="text-white">service={incident.service}</div>
          <div className="text-yellow-400">message="{incident.alert}"</div>
          <div className="text-red-300">metric={incident.metric}</div>
          <div className="mt-3 text-green-400 group-hover:underline">→ Respond to incident</div>
        </div>
      </a>
    </div>
  )
}

// Variation 5: iOS notification style
export const StruggleWidget5 = () => {
  const incident = LIVE_INCIDENTS[4]
  return (
    <div className="py-4">
      <a
        href={`/topics/${incident.slug}`}
        className="block p-4 rounded-2xl bg-white/90 dark:bg-zinc-800/90 backdrop-blur border border-zinc-200 dark:border-zinc-700 shadow-lg hover:shadow-xl transition-all group"
      >
        <div className="flex items-start gap-3">
          <div className="w-10 h-10 rounded-xl bg-red-500 flex items-center justify-center flex-shrink-0">
            <span className="text-white text-lg">🚨</span>
          </div>
          <div className="flex-1 min-w-0">
            <div className="flex items-center justify-between mb-1">
              <span className="font-semibold text-zinc-900 dark:text-white text-sm">Incident Alert</span>
              <span className="text-zinc-500 text-xs">{incident.time}</span>
            </div>
            <div className="text-zinc-700 dark:text-zinc-300 text-sm font-medium">{incident.service}: {incident.alert}</div>
            <div className="text-zinc-500 text-xs mt-1">{incident.metric} • On-call: {incident.oncall}</div>
          </div>
        </div>
        <div className="mt-3 pt-3 border-t border-zinc-200 dark:border-zinc-700 text-xs text-blue-600 dark:text-blue-400 text-center group-hover:underline">
          Tap to respond
        </div>
      </a>
    </div>
  )
}

// Variation 6: Opsgenie/alert banner style
export const StruggleWidget6 = () => {
  const incident = LIVE_INCIDENTS[5]
  return (
    <div className="py-4">
      <a
        href={`/topics/${incident.slug}`}
        className="flex items-center gap-4 p-4 rounded-lg bg-gradient-to-r from-red-600 to-red-500 hover:from-red-500 hover:to-red-400 transition-colors group"
      >
        <div className="flex-shrink-0">
          <div className="w-12 h-12 rounded-full bg-white/20 flex items-center justify-center">
            <span className="text-2xl">⚠️</span>
          </div>
        </div>
        <div className="flex-1 min-w-0">
          <div className="text-white/80 text-xs font-medium uppercase tracking-wide mb-1">Critical Alert • {incident.time}</div>
          <div className="text-white font-semibold text-lg truncate">{incident.alert}</div>
          <div className="text-white/70 text-sm">{incident.service} • {incident.metric}</div>
        </div>
        <div className="text-white/90 text-sm font-medium group-hover:underline whitespace-nowrap">
          ACK →
        </div>
      </a>
    </div>
  )
}

// Variation 7: Status page incident style
export const StruggleWidget7 = () => {
  const incident = LIVE_INCIDENTS[6]
  return (
    <div className="py-4">
      <a
        href={`/topics/${incident.slug}`}
        className="block p-4 rounded-lg bg-white dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 hover:border-orange-300 dark:hover:border-orange-500/50 transition-colors group"
      >
        <div className="flex items-center gap-2 mb-3">
          <div className="w-3 h-3 rounded-full bg-orange-500 animate-pulse"></div>
          <span className="text-orange-600 dark:text-orange-400 font-semibold text-sm">Investigating</span>
          <span className="text-zinc-400 text-xs ml-auto">{incident.time}</span>
        </div>
        <div className="text-zinc-900 dark:text-white font-semibold mb-2">{incident.alert}</div>
        <div className="text-sm text-zinc-600 dark:text-zinc-400 mb-3">
          We're investigating reports of issues with <span className="font-mono text-zinc-900 dark:text-white">{incident.service}</span>.
          Current metrics showing {incident.metric}.
        </div>
        <div className="text-xs text-blue-600 dark:text-blue-400 group-hover:underline">Help debug this →</div>
      </a>
    </div>
  )
}

// Variation 8: Grafana-style panel
export const StruggleWidget8 = () => {
  const incident = LIVE_INCIDENTS[7]
  return (
    <div className="py-4">
      <a
        href={`/topics/${incident.slug}`}
        className="block rounded-lg bg-[#181b1f] border border-zinc-800 overflow-hidden hover:border-red-500/50 transition-colors group"
      >
        <div className="px-4 py-2 bg-[#1f2229] border-b border-zinc-800 flex items-center justify-between">
          <span className="text-zinc-300 text-sm font-medium">{incident.service}</span>
          <span className="px-2 py-0.5 rounded text-xs font-bold bg-red-500/20 text-red-400 border border-red-500/30">ALERTING</span>
        </div>
        <div className="p-4">
          <div className="text-red-400 text-2xl font-bold mb-1">{incident.metric}</div>
          <div className="text-zinc-400 text-sm mb-3">{incident.alert}</div>
          <div className="h-16 flex items-end gap-0.5">
            {[30,35,32,38,45,52,68,85,92,89,95,98].map((h, i) => (
              <div
                key={i}
                className={`flex-1 rounded-t ${i >= 8 ? 'bg-red-500' : 'bg-green-500'}`}
                style={{height: `${h}%`}}
              ></div>
            ))}
          </div>
          <div className="mt-3 text-xs text-blue-400 group-hover:underline">Investigate →</div>
        </div>
      </a>
    </div>
  )
}

// Variation 9: Discord/chat notification
export const StruggleWidget9 = () => {
  const incident = LIVE_INCIDENTS[8]
  return (
    <div className="py-4">
      <a
        href={`/topics/${incident.slug}`}
        className="block p-4 rounded-lg bg-[#2b2d31] hover:bg-[#35373c] transition-colors group"
      >
        <div className="flex items-start gap-3">
          <div className="w-10 h-10 rounded-full bg-red-500 flex items-center justify-center flex-shrink-0">
            <span className="text-white text-sm font-bold">🤖</span>
          </div>
          <div className="flex-1">
            <div className="flex items-center gap-2 mb-1">
              <span className="text-white font-semibold">Alert Bot</span>
              <span className="px-1.5 py-0.5 rounded text-xs bg-[#5865f2] text-white">BOT</span>
              <span className="text-zinc-500 text-xs">Today at {new Date().toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'})}</span>
            </div>
            <div className="p-3 rounded bg-[#1e1f22] border-l-4 border-red-500">
              <div className="text-red-400 font-semibold text-sm mb-1">🚨 {incident.service}</div>
              <div className="text-zinc-300 text-sm">{incident.alert}</div>
              <div className="text-zinc-500 text-xs mt-2">{incident.metric} • {incident.time}</div>
            </div>
            <div className="mt-2 text-xs text-blue-400 group-hover:underline">React to this incident →</div>
          </div>
        </div>
      </a>
    </div>
  )
}

// Variation 10: Email notification preview
export const StruggleWidget10 = () => {
  const incident = LIVE_INCIDENTS[9]
  return (
    <div className="py-4">
      <a
        href={`/topics/${incident.slug}`}
        className="block p-4 rounded-lg bg-white dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 hover:shadow-lg transition-all group"
      >
        <div className="flex items-center gap-3 mb-3 pb-3 border-b border-zinc-100 dark:border-zinc-700">
          <div className="w-8 h-8 rounded-full bg-red-100 dark:bg-red-500/20 flex items-center justify-center">
            <span className="text-red-600 dark:text-red-400 text-sm">📧</span>
          </div>
          <div className="flex-1 min-w-0">
            <div className="text-zinc-900 dark:text-white font-semibold text-sm truncate">alerts@monitoring.internal</div>
            <div className="text-zinc-500 text-xs">{incident.time}</div>
          </div>
          <div className="w-2 h-2 rounded-full bg-blue-500"></div>
        </div>
        <div className="text-zinc-900 dark:text-white font-semibold mb-1">[CRITICAL] {incident.service} - {incident.alert}</div>
        <div className="text-zinc-600 dark:text-zinc-400 text-sm line-clamp-2">
          Alert triggered for {incident.service}. Current reading: {incident.metric}.
          Immediate attention required. On-call: {incident.oncall}
        </div>
        <div className="mt-3 text-xs text-blue-600 dark:text-blue-400 group-hover:underline">Open this incident →</div>
      </a>
    </div>
  )
}

// Array of all widgets for easy access
export const STRUGGLE_WIDGETS = [
  StruggleWidget1,
  StruggleWidget2,
  StruggleWidget3,
  StruggleWidget4,
  StruggleWidget5,
  StruggleWidget6,
  StruggleWidget7,
  StruggleWidget8,
  StruggleWidget9,
  StruggleWidget10,
]

export default STRUGGLE_WIDGETS