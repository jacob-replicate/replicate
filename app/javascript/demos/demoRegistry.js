/**
 * Demo Registry - central place for all demo conversations
 */

import { INCIDENT_MESSAGES } from './dnsIncidentDemo'
import { REDIS_INCIDENT_MESSAGES } from './redisOomDemo'

export const DEMO_REGISTRY = {
  'inc-4521-cart-500s': {
    messages: INCIDENT_MESSAGES,
  },
  'inc-3824-redis-oom': {
    messages: REDIS_INCIDENT_MESSAGES,
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
  console.log('[loadDemo] called with channelId:', channelId)
  const conversation = fetchConversation(channelId)
  console.log('[loadDemo] fetchConversation result:', conversation)
  if (!conversation) {
    console.log('[loadDemo] No conversation found, returning')
    return
  }

  console.log('[loadDemo] Setting timeout for 100ms')
  setTimeout(() => {
    console.log('[loadDemo] Timeout fired')
    console.log('[loadDemo] window.ReplicateConversation:', window.ReplicateConversation)
    if (window.ReplicateConversation) {
      console.log('[loadDemo] Calling clear()')
      window.ReplicateConversation.clear()
      console.log('[loadDemo] Calling setChannelName:', '#' + channelId)
      window.ReplicateConversation.setChannelName('#' + channelId)
      console.log('[loadDemo] Calling loadMessages with', conversation.messages?.length, 'messages')
      window.ReplicateConversation.loadMessages(conversation.messages)
      console.log('[loadDemo] Done loading')
    } else {
      console.log('[loadDemo] window.ReplicateConversation is null/undefined')
    }
  }, 100)
}

/**
 * Initialize the conversation demo
 */
export const initConversation = () => {
  const defaultChannel = 'inc-4521-cart-500s'

  const waitForReady = () => {
    if (window.ReplicateConversation?.navigate) {
      window.ReplicateConversation.loadDemo = loadDemo
      window.ReplicateConversation.navigate(`/conversations/${defaultChannel}`)

      window.ReplicateConversation.onReady((api) => {
        api.setChannelName('#' + defaultChannel)
        api.streamMessages(DEMO_REGISTRY[defaultChannel].messages)
      })
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