/**
 * Demo Registry - central place for all demo conversations
 */

import { INCIDENT_MESSAGES } from './dnsIncidentDemo'
import { REDIS_INCIDENT_MESSAGES } from './redisOomDemo'
import { DESIGN_DOC_DEMOS } from './designDocDemo'

export const DEMO_REGISTRY = {
  'inc-4521-cart-500s': {
    messages: INCIDENT_MESSAGES,
  },
  'inc-3824-redis-oom': {
    messages: REDIS_INCIDENT_MESSAGES,
  },
  // Design docs
  'rfc-auth-service': {
    messages: DESIGN_DOC_DEMOS['rfc-auth-service'],
  },
  'adr-event-sourcing': {
    messages: DESIGN_DOC_DEMOS['adr-event-sourcing'],
  },
  'rfc-multi-region': {
    messages: DESIGN_DOC_DEMOS['rfc-multi-region'],
  },
}

/**
 * Fetch conversation data by channel ID
 */
export const fetchConversation = (channelId) => {
  const demo = DEMO_REGISTRY[channelId]
  if (!demo) return null
  return {
    channelId,
    messages: demo.messages,
  }
}

/**
 * Load a specific demo by channel ID
 */
export const loadDemo = (channelId) => {
  const conversation = fetchConversation(channelId)
  if (!conversation) {
    return
  }

  setTimeout(() => {
    if (window.ReplicateConversation) {
      window.ReplicateConversation.clear()
      window.ReplicateConversation.setChannelName('#' + channelId)
      window.ReplicateConversation.loadMessages(conversation.messages)
    } else {
    }
  }, 100)
}

/**
 * Initialize the conversation demo
 */
export const initConversation = () => {
  const defaultChannel = 'inc-4521-cart-500s'

  // Only auto-navigate if on root or conversations path
  const path = window.location.pathname
  const shouldAutoNavigate = path === '/' || path.startsWith('/conversations')

  const waitForReady = () => {
    if (window.ReplicateConversation?.navigate) {
      window.ReplicateConversation.loadDemo = loadDemo

      if (shouldAutoNavigate) {
        window.ReplicateConversation.navigate(`/conversations/${defaultChannel}`)

        window.ReplicateConversation.onReady((api) => {
          api.setChannelName('#' + defaultChannel)
          api.streamMessages(DEMO_REGISTRY[defaultChannel].messages)
        })
      }
    } else {
      setTimeout(waitForReady, 50)
    }
  }

  waitForReady()
}

// Start when DOM is ready
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initConversation)
} else {
  initConversation()
}