/**
 * Demo channel data for the conversation UI
 * This is sample data - in production, channels would come from an API
 */

export const DEMO_CHANNELS = [
  // Active incidents (filtered by id prefix 'inc-')
  { id: 'inc-3815-db-locks', name: 'inc-3815-db-locks', unreadCount: 0 },
  { id: 'inc-3824-redis-oom', name: 'inc-3824-redis-oom', unreadCount: 3 },
  { id: 'inc-3819-api-latency', name: 'inc-3819-api-latency', unreadCount: 0 },
  // Ops channels
  { id: 'ops-alerts', name: 'ops-alerts', section: 'ops', unreadCount: 12 },
  { id: 'oncall', name: 'oncall', section: 'ops', unreadCount: 1 },
  { id: 'oncall-leads', name: 'oncall-leads', section: 'ops', unreadCount: 0, isPrivate: true },
  { id: 'deploy-prod', name: 'deploy-prod', section: 'ops', unreadCount: 0 },
  { id: 'deploy-staging', name: 'deploy-staging', section: 'ops', unreadCount: 0, isMuted: true },
  // Team channels
  { id: 'platform-eng', name: 'platform-eng', section: 'teams', unreadCount: 5 },
  { id: 'backend', name: 'backend', section: 'teams', unreadCount: 0 },
  { id: 'frontend', name: 'frontend', section: 'teams', unreadCount: 2 },
  { id: 'infra', name: 'infra', section: 'teams', unreadCount: 0 },
  { id: 'sre-team', name: 'sre-team', section: 'teams', unreadCount: 0 },
  { id: 'security', name: 'security', section: 'teams', unreadCount: 1 },
  { id: 'security-incidents', name: 'security-incidents', section: 'teams', unreadCount: 0, isPrivate: true },
  // General
  { id: 'engineering', name: 'engineering', section: 'general', unreadCount: 0 },
  { id: 'random', name: 'random', section: 'general', unreadCount: 0, isMuted: true },
  { id: 'watercooler', name: 'watercooler', section: 'general', unreadCount: 0 },
  // DMs (filtered by id prefix 'dm-')
  { id: 'dm-maya', name: 'maya', unreadCount: 0 },
  { id: 'dm-alex', name: 'alex', unreadCount: 2 },
  { id: 'dm-daniel', name: 'daniel', unreadCount: 0 },
  { id: 'dm-sarah', name: 'sarah', unreadCount: 0 },
  { id: 'dm-chen', name: 'chen', unreadCount: 1 },
  { id: 'dm-priya', name: 'priya', unreadCount: 0 },
]

/**
 * Section configuration for the channel sidebar
 */
export const DEMO_SECTIONS = [
  {
    id: 'incidents',
    label: 'Incidents',
    filter: (c) => c.id.startsWith('inc-'),
    action: {
      label: 'New',
      icon: 'plus',
      onClick: () => alert('New incident flow coming soon!'),
    },
  },
  {
    id: 'ops',
    label: 'Ops',
    filter: (c) => c.section === 'ops',
  },
  {
    id: 'teams',
    label: 'Teams',
    filter: (c) => c.section === 'teams',
  },
  {
    id: 'general',
    label: 'General',
    filter: (c) => c.section === 'general',
  },
  {
    id: 'dms',
    label: 'Direct Messages',
    filter: (c) => c.id.startsWith('dm-'),
    prefix: '',
  },
]

export const DEFAULT_CHANNEL_ID = 'inc-3815-db-locks'