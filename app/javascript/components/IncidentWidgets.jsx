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

// Add more polished widgets here as they get approved...

// Export all polished widgets
export const INCIDENT_WIDGETS = [
  IncidentWidget1,
]

export default INCIDENT_WIDGETS