/**
 * Demo Registry - central place for all demo conversations
 */

import { INCIDENT_MESSAGES, AUTH_INCIDENT_MESSAGES, PARTITIONING_INCIDENT_MESSAGES } from './demoConversation'

export const DEMO_REGISTRY = {
  'dns': {
    messages: INCIDENT_MESSAGES,
  },
  'authentication': {
    messages: AUTH_INCIDENT_MESSAGES,
  },
  'partitioning': {
    messages: PARTITIONING_INCIDENT_MESSAGES,
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
 * @param {string} channelId - Channel to load
 * @param {object} options - { stream: boolean } - if true, animate typing indicators
 */
export const loadDemo = (channelId, options = {}) => {
  const { stream = false } = options
  const conversation = fetchConversation(channelId)
  if (!conversation) {
    return
  }

  const tryLoad = (attempts = 0) => {
    if (window.ReplicateConversation?.loadMessages) {
      window.ReplicateConversation.clear()
      window.ReplicateConversation.setChannelName('#' + channelId)

      if (stream) {
        // Animated: typing indicators, staggered messages
        window.ReplicateConversation.streamMessages(conversation.messages)
      } else {
        // Instant: populate immediately
        window.ReplicateConversation.loadMessages(conversation.messages)
      }
    } else if (attempts < 30) {
      // Retry up to 30 times (3 seconds total)
      setTimeout(() => tryLoad(attempts + 1), 100)
    }
  }

  tryLoad()
}

/**
 * Initialize the conversation demo
 * Set DEMO_STREAM=true to enable typing animation on first load
 */
const DEMO_STREAM = false // Toggle this to enable/disable typing animation

export const initConversation = () => {
  // Just attach loadDemo to window API when ready
  // ConversationView handles initial load on mount
  const attachLoadDemo = () => {
    if (window.ReplicateConversation) {
      window.ReplicateConversation.loadDemo = loadDemo
    } else {
      setTimeout(attachLoadDemo, 100)
    }
  }
  attachLoadDemo()
}

// Start when DOM is ready
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initConversation)
} else {
  initConversation()
}