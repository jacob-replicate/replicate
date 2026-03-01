/**
 * Demo Registry - central place for all demo conversations
 */

import { INCIDENT_MESSAGES } from './demoConversation'

export const DEMO_REGISTRY = {
  'dns': {
    messages: INCIDENT_MESSAGES,
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
    }
  }, 100)
}

/**
 * Initialize the conversation demo
 */
export const initConversation = () => {
  const defaultChannel = 'dns'

  // Only auto-navigate if on root or conversations path
  const path = window.location.pathname
  const shouldAutoNavigate = path === '/' || path.startsWith('/conversations')

  const waitForReady = () => {
    if (window.ReplicateConversation?.navigate) {
      window.ReplicateConversation.loadDemo = loadDemo

      if (shouldAutoNavigate) {
        window.ReplicateConversation.navigate(`/${defaultChannel}`)

        window.ReplicateConversation.onReady((api) => {
          api.setChannelName('#' + defaultChannel)
          api.streamMessages(DEMO_REGISTRY[defaultChannel]?.messages || [])
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