/**
 * Demo channel data for the conversation UI
 * This is sample data - in production, channels would come from an API
 *
 * Shape matches ConversationContext:
 * - uuid: unique identifier used in URLs and API calls
 * - name: display name (can repeat across users)
 * - section: for grouping in sidebar
 * - unreadCount, isMuted, isPrivate: UI state
 * - messages, messagesLoading: set by context provider
 */

export const DEMO_CHANNELS = [
  // Active incidents (filtered by uuid prefix 'inc-')
  { uuid: 'inc-4521-cart-500s', id: 'inc-4521-cart-500s', name: 'inc-4521-cart-500s', unreadCount: 0 },
  { uuid: 'inc-4519-redis-oom', id: 'inc-4519-redis-oom', name: 'inc-4519-redis-oom', unreadCount: 3 },
  { uuid: 'inc-4517-payments-timeout', id: 'inc-4517-payments-timeout', name: 'inc-4517-payments-timeout', unreadCount: 0 },
  // Topics - SRE/Security learning channels
  { uuid: 'data-migrations', id: 'data-migrations', name: 'data-migrations', section: 'topics', unreadCount: 2 },
  { uuid: 'consensus', id: 'consensus', name: 'consensus', section: 'topics', unreadCount: 0 },
  { uuid: 'zero-trust', id: 'zero-trust', name: 'zero-trust', section: 'topics', unreadCount: 1 },
  { uuid: 'chaos-engineering', id: 'chaos-engineering', name: 'chaos-engineering', section: 'topics', unreadCount: 0 },
  { uuid: 'incident-response', id: 'incident-response', name: 'incident-response', section: 'topics', unreadCount: 4 },
  { uuid: 'k8s-networking', id: 'k8s-networking', name: 'k8s-networking', section: 'topics', unreadCount: 0 },
  // Ops channels
  { uuid: 'oncall-primary', id: 'oncall-primary', name: 'oncall-primary', section: 'ops', unreadCount: 1 },
  { uuid: 'oncall-secondary', id: 'oncall-secondary', name: 'oncall-secondary', section: 'ops', unreadCount: 0, isPrivate: true },
  { uuid: 'postmortems', id: 'postmortems', name: 'postmortems', section: 'ops', unreadCount: 0 },
  // DMs (filtered by uuid prefix 'dm-')
  { uuid: 'dm-sarah-chen', id: 'dm-sarah-chen', name: 'Sarah Chen', unreadCount: 0 },
  { uuid: 'dm-alex-kumar', id: 'dm-alex-kumar', name: 'Alex Kumar', unreadCount: 2 },
  { uuid: 'dm-jordan-miles', id: 'dm-jordan-miles', name: 'Jordan Miles', unreadCount: 0 },
]

/**
 * Section configuration for the channel sidebar
 * Filters support both uuid and id for backward compatibility
 */
export const DEMO_SECTIONS = [
  {
    id: 'incidents',
    label: 'Incidents',
    filter: (c) => (c.uuid || c.id).startsWith('inc-'),
    action: {
      label: 'New',
      icon: 'plus',
      onClick: () => alert('New incident flow coming soon!'),
    },
  },
  {
    id: 'topics',
    label: 'Topics',
    filter: (c) => c.section === 'topics',
    action: {
      label: 'New',
      icon: 'plus',
      onClick: () => alert('New topic flow coming soon!'),
    },
  },
  {
    id: 'ops',
    label: 'Ops',
    filter: (c) => c.section === 'ops',
  },
  {
    id: 'dms',
    label: 'Direct Messages',
    filter: (c) => (c.uuid || c.id).startsWith('dm-'),
    prefix: '',
  },
]

export const DEFAULT_CHANNEL_ID = 'inc-4521-cart-500s'