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

// Widget 1: Compact PagerDuty style (KEEPER)
export const IncidentWidget1 = () => {
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
          <div className="px-5 py-2.5 rounded bg-white hover:bg-zinc-100 text-zinc-900 text-sm font-medium transition-colors tracking-normal">
            Respond →
          </div>
        </div>
      </a>
    </div>
  )
}

// Widget 2: Monitor Alert - Light Datadog/Slack warning style (KEEPER)
export const IncidentWidget2 = () => {
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
            <span>78% of member space consumed</span>
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
            {/* Threshold line */}
            <div className="absolute top-0 w-full border-t-2 border-dashed border-red-400/60" />
            {/* Area chart SVG */}
            <svg viewBox="0 0 200 40" className="w-full h-12" preserveAspectRatio="none">
              {/* Gradient fill */}
              <defs>
                <linearGradient id="slruGradient" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="0%" stopColor="#f59e0b" stopOpacity="0.4" />
                  <stop offset="100%" stopColor="#fbbf24" stopOpacity="0.1" />
                </linearGradient>
              </defs>
              {/* Area path - usage trending up over 7 days */}
              <path
                d="M0,32 L15,30 L30,31 L50,28 L70,26 L90,24 L110,22 L130,18 L150,14 L170,12 L185,10 L200,9 L200,40 L0,40 Z"
                fill="url(#slruGradient)"
              />
              {/* Line on top */}
              <path
                d="M0,32 L15,30 L30,31 L50,28 L70,26 L90,24 L110,22 L130,18 L150,14 L170,12 L185,10 L200,9"
                fill="none"
                stroke="#f59e0b"
                strokeWidth="2"
                strokeLinecap="round"
                strokeLinejoin="round"
              />
            </svg>
          </div>
          {/* Time labels */}
          <div className="flex justify-between text-[10px] text-amber-600/70 mt-1">
            <span>24h ago</span>
            <span>now</span>
          </div>
        </div>

        {/* CTA */}
        <div className="px-5 pb-4 pt-1">
          <span className="text-amber-700 text-sm font-medium hover:text-amber-900 transition-colors">
            Investigate this alert<span className="ml-1">→</span>
          </span>
        </div>
      </a>
    </div>
  )
}

// Widget 3: Slack incident thread - full realistic conversation (KEEPER)
export const IncidentWidget3 = () => {
  return (
    <div className="py-4">
      <a
        href="/topics/resource-limits"
        className="block rounded-lg overflow-hidden transition-all hover:shadow-xl border border-zinc-300 bg-white shadow-sm group"
      >
        {/* Window chrome */}
        <div className="bg-zinc-100 border-b border-zinc-200 px-3 py-2 flex items-center gap-2">
          <div className="flex items-center gap-1.5">
            <div className="w-3 h-3 rounded-full bg-red-400"></div>
            <div className="w-3 h-3 rounded-full bg-amber-400"></div>
            <div className="w-3 h-3 rounded-full bg-green-400"></div>
          </div>
          <div className="flex-1 flex items-center justify-center">
            <span className="text-zinc-500 text-xs font-medium">#incidents — Slack</span>
          </div>
          <div className="w-[52px]"></div>
        </div>

        {/* Messages */}
        <div className="relative">
          <div className="px-4 py-4 space-y-5">
            {/* Message 1 - Alert */}
            <div className="flex gap-3">
              <img src="/profile-photo-1.jpg" alt="" className="w-10 h-10 rounded flex-shrink-0" />
              <div className="flex-1">
                <div className="flex items-baseline gap-2">
                  <span className="font-bold text-zinc-900 text-[15px]">k8s-alerts</span>
                  <span className="text-zinc-400 text-xs">2:47 AM</span>
                </div>
                <div className="border-l-4 border-red-500 bg-zinc-50 rounded-r px-3 py-2 mt-1">
                  <div className="font-mono text-sm text-red-600 mb-1">[OOMKilled] checkout-worker-6f8b9 restarting</div>
                  <div className="text-zinc-800 text-sm font-medium">Container exceeded memory limit during GC pause</div>
                  <div className="text-zinc-500 text-xs mt-1">3rd restart in 10min • node memory pressure detected</div>
                </div>
              </div>
            </div>

            {/* Message 2 */}
            <div className="flex gap-3">
              <img src="/profile-photo-2.jpg" alt="" className="w-10 h-10 rounded flex-shrink-0" />
              <div>
                <div className="flex items-baseline gap-2">
                  <span className="font-bold text-zinc-900 text-[15px]">maya</span>
                  <span className="text-zinc-400 text-xs">2:48 AM</span>
                </div>
                <div className="text-zinc-800 text-[15px] mt-0.5">on it, pulling logs now</div>
              </div>
            </div>

            {/* Message 3 - with code */}
            <div className="flex gap-3">
              <img src="/profile-photo-2.jpg" alt="" className="w-10 h-10 rounded flex-shrink-0" />
              <div className="flex-1">
                <div className="flex items-baseline gap-2">
                  <span className="font-bold text-zinc-900 text-[15px]">maya</span>
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
              <img src="/profile-photo-3.jpg" alt="" className="w-10 h-10 rounded flex-shrink-0" />
              <div className="flex-1">
                <div className="flex items-baseline gap-2">
                  <span className="font-bold text-zinc-900 text-[15px]">daniel</span>
                  <span className="text-zinc-400 text-xs">2:51 AM</span>
                </div>
                <div className="text-zinc-800 text-[15px] mt-0.5">seeing the same on worker-7 and worker-12. looks like tuesday's deploy bumped the heap from 1.5G to 1.8G but we didn't touch the cgroup limits</div>
              </div>
            </div>

            {/* Message 5 */}
            <div className="flex gap-3">
              <img src="/profile-photo-2.jpg" alt="" className="w-10 h-10 rounded flex-shrink-0" />
              <div>
                <div className="flex items-baseline gap-2">
                  <span className="font-bold text-zinc-900 text-[15px]">maya</span>
                  <span className="text-zinc-400 text-xs">2:52 AM</span>
                </div>
                <div className="text-zinc-800 text-[15px] mt-0.5">that tracks. the GC is trying to expand but hitting the wall. want me to bump limits to 2.5Gi or roll back?</div>
              </div>
            </div>

            {/* Message 6 */}
            <div className="flex gap-3">
              <img src="/profile-photo-3.jpg" alt="" className="w-10 h-10 rounded flex-shrink-0" />
              <div>
                <div className="flex items-baseline gap-2">
                  <span className="font-bold text-zinc-900 text-[15px]">daniel</span>
                  <span className="text-zinc-400 text-xs">2:52 AM</span>
                </div>
                <div className="text-zinc-800 text-[15px] mt-0.5">roll back for now, we're in the middle of the flash sale. let's bump limits in the morning when traffic dies down</div>
              </div>
            </div>

            {/* Message 7 */}
            <div className="flex gap-3">
              <img src="/profile-photo-2.jpg" alt="" className="w-10 h-10 rounded flex-shrink-0" />
              <div>
                <div className="flex items-baseline gap-2">
                  <span className="font-bold text-zinc-900 text-[15px]">maya</span>
                  <span className="text-zinc-400 text-xs">2:53 AM</span>
                </div>
                <div className="text-zinc-800 text-[15px] mt-0.5">rolling back now ↩️</div>
              </div>
            </div>
          </div>

          {/* Fade gradient overlay with CTA */}
          <div className="absolute bottom-0 left-0 right-0 h-40 bg-gradient-to-t from-white via-white/95 to-transparent pointer-events-none flex items-end justify-center pb-5">
            <span className="pointer-events-auto bg-blue-600 hover:bg-blue-700 text-white text-sm font-semibold px-5 py-2.5 rounded-full shadow-lg shadow-blue-500/25 transition-all hover:scale-105">
              What would you do? →
            </span>
          </div>
        </div>
      </a>
    </div>
  )
}

// Add more polished widgets here as they get approved...

// Export all polished widgets
export const INCIDENT_WIDGETS = [
  IncidentWidget1,
  IncidentWidget2,
  IncidentWidget3,
]

export default INCIDENT_WIDGETS