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
  // Ops channels
  { uuid: 'prod-alerts', id: 'prod-alerts', name: 'prod-alerts', section: 'ops', unreadCount: 8 },
  { uuid: 'deploys', id: 'deploys', name: 'deploys', section: 'ops', unreadCount: 0 },
  { uuid: 'oncall-primary', id: 'oncall-primary', name: 'oncall-primary', section: 'ops', unreadCount: 1 },
  { uuid: 'oncall-secondary', id: 'oncall-secondary', name: 'oncall-secondary', section: 'ops', unreadCount: 0, isPrivate: true },
  { uuid: 'change-management', id: 'change-management', name: 'change-management', section: 'ops', unreadCount: 0, isMuted: true },
  // Team channels
  { uuid: 'eng-backend', id: 'eng-backend', name: 'eng-backend', section: 'teams', unreadCount: 5 },
  { uuid: 'eng-frontend', id: 'eng-frontend', name: 'eng-frontend', section: 'teams', unreadCount: 2 },
  { uuid: 'eng-platform', id: 'eng-platform', name: 'eng-platform', section: 'teams', unreadCount: 0 },
  { uuid: 'eng-data', id: 'eng-data', name: 'eng-data', section: 'teams', unreadCount: 0 },
  { uuid: 'security', id: 'security', name: 'security', section: 'teams', unreadCount: 1, isPrivate: true },
  // General
  { uuid: 'announcements', id: 'announcements', name: 'announcements', section: 'general', unreadCount: 0 },
  { uuid: 'eng-random', id: 'eng-random', name: 'eng-random', section: 'general', unreadCount: 0, isMuted: true },
  // DMs (filtered by uuid prefix 'dm-')
  { uuid: 'dm-sarah-chen', id: 'dm-sarah-chen', name: 'Sarah Chen', unreadCount: 0 },
  { uuid: 'dm-alex-kumar', id: 'dm-alex-kumar', name: 'Alex Kumar', unreadCount: 2 },
  { uuid: 'dm-jordan-miles', id: 'dm-jordan-miles', name: 'Jordan Miles', unreadCount: 0 },
  { uuid: 'dm-priya-patel', id: 'dm-priya-patel', name: 'Priya Patel', unreadCount: 1 },
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
    filter: (c) => (c.uuid || c.id).startsWith('dm-'),
    prefix: '',
  },
]

export const DEFAULT_CHANNEL_ID = 'inc-4521-cart-500s'