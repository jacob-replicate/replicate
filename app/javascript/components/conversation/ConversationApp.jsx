import React, { useEffect, useRef, useCallback, useState } from 'react'
import ReactDOM from 'react-dom/client'
import { HashRouter, Routes, Route, Navigate, useParams, useNavigate } from 'react-router-dom'
import Conversation from './Conversation'
import TopicNav from './TopicNav'
import BackgroundNotification from './BackgroundNotification'
import useConversation from '../../hooks/useConversation'

// Default topics
const TOPICS = [
  { name: 'compute', code: 'compute' },
  { name: 'delivery', code: 'delivery' },
  { name: 'governance', code: 'governance' },
  { name: 'networking', code: 'networking' },
  { name: 'observability', code: 'observability' },
  { name: 'storage', code: 'storage' },
]

// Timing constants for message streaming
const TYPING_DURATION = 600
const MIN_GAP_BETWEEN_AUTHORS = 400

const sleep = (ms) => new Promise(resolve => setTimeout(resolve, ms))

/**
 * ConversationView - renders a conversation for a specific UUID
 * Exposes the conversation API globally for demo streaming
 */
const ConversationView = ({ apiRef }) => {
  const { uuid } = useParams()
  const navigate = useNavigate()
  const [channelName, setChannelName] = useState('#ops-alerts')

  const {
    messages,
    isTyping,
    addMessage,
    updateMessage,
    removeMessage,
    clear,
    setTyping,
    setExpectedSequence,
    sendUserMessage,
  } = useConversation({ conversationId: null }) // No ActionCable for demo

  // Use refs for functions to avoid stale closures in async streamMessages
  const addMessageRef = useRef(addMessage)
  const setTypingRef = useRef(setTyping)
  const updateMessageRef = useRef(updateMessage)

  useEffect(() => {
    addMessageRef.current = addMessage
    setTypingRef.current = setTyping
    updateMessageRef.current = updateMessage
  })

  /**
   * Animate reactions ticking up to their final counts
   * Runs async/non-blocking - doesn't hold up message streaming
   */
  const animateReactions = useCallback((messageId, finalReactions) => {
    if (!finalReactions || finalReactions.length === 0) return

    // Start after 3+ seconds
    const baseDelay = 3000 + Math.random() * 2000

    setTimeout(() => {
      // Initialize all reactions at count 0
      const currentCounts = finalReactions.map(() => 0)
      updateMessageRef.current(messageId, {
        reactions: finalReactions.map((r, i) => ({ ...r, count: currentCounts[i] }))
      })

      // For each reaction, tick up to final count with random intervals
      finalReactions.forEach((reaction, reactionIndex) => {
        let tickCount = 0
        const tickUp = () => {
          tickCount++
          currentCounts[reactionIndex] = tickCount

          updateMessageRef.current(messageId, {
            reactions: finalReactions.map((r, i) => ({ ...r, count: currentCounts[i] }))
          })

          if (tickCount < reaction.count) {
            // Random interval between ticks (300ms - 1200ms)
            setTimeout(tickUp, 300 + Math.random() * 900)
          }
        }

        // Stagger start of each reaction's ticking
        setTimeout(tickUp, Math.random() * 1500)
      })
    }, baseDelay)
  }, [])

  /**
   * Stream messages with typing indicators and delays
   * Shows typing indicator before each new message, then streams components
   *
   * Thread replies (messages with parent_message_id) are added instantly
   * without typing indicators - they just update the thread reply count
   *
   * Reactions are animated asynchronously after the message appears
   */
  const streamMessages = useCallback(async (messagesToStream) => {
    for (const message of messagesToStream) {
      // Thread replies don't get typing indicators - just add them instantly
      if (message.parent_message_id) {
        addMessageRef.current(message)
        continue
      }

      // Show typing indicator for this author
      setTypingRef.current(message.author)
      await sleep(TYPING_DURATION)
      setTypingRef.current(false)

      // Extract reactions to animate separately
      const { reactions, ...messageWithoutReactions } = message

      // Add the message without reactions first
      addMessageRef.current(messageWithoutReactions)

      // Animate reactions asynchronously (non-blocking)
      if (reactions && reactions.length > 0) {
        animateReactions(message.id, reactions)
      }

      // Small delay between messages
      await sleep(MIN_GAP_BETWEEN_AUTHORS)
    }
  }, [animateReactions])

  // Expose API globally for external streaming
  useEffect(() => {
    const api = {
      addMessage,
      updateMessage,
      removeMessage,
      clear,
      setTyping,
      setExpectedSequence,
      streamMessages,
      setChannelName,
      getMessages: () => messages,
      isTyping: () => isTyping,
    }

    // Store in ref so parent can access
    if (apiRef) {
      apiRef.current = api
    }

    // Expose globally
    window.ReplicateConversation = {
      ...api,
      onReady: (callback) => {
        // Already ready, call immediately
        callback(api)
      },
    }

    // Fire any queued onReady callbacks
    if (window._replicateConversationReadyCallbacks) {
      window._replicateConversationReadyCallbacks.forEach(cb => cb(api))
      window._replicateConversationReadyCallbacks = []
    }

    return () => {
      // Don't clean up global API - let it persist
    }
  }, [addMessage, updateMessage, removeMessage, clear, setTyping, setExpectedSequence, setChannelName, messages, isTyping, apiRef])

  // Handle topic change from dropdown
  const handleTopicChange = useCallback((newTopic) => {
    navigate(`/${newTopic.code}`)
  }, [navigate])

  // Handle message selection (for multiple choice, etc)
  // optionText is the text of the selected option (for sending as a message)
  const handleSelect = useCallback((messageId, optionId, optionText) => {
    // Update the message to show selection
    updateMessage(messageId, {
      metadata: {
        ...messages.find(m => m.id === messageId)?.metadata,
        selectedId: optionId
      }
    })

    // If we have optionText, send it as the user's response
    if (optionText) {
      sendUserMessage(optionText)
    }
  }, [updateMessage, messages, sendUserMessage])

  return (
    <Conversation
      messages={messages}
      isTyping={isTyping}
      onSend={sendUserMessage}
      onSelect={handleSelect}
      topics={TOPICS}
      currentTopic={currentTopic}
      onTopicChange={handleTopicChange}
      channelName={channelName}
      className=""
    />
  )
}

/**
 * ConversationApp - Root component with routing
 */
const ConversationApp = () => {
  const apiRef = useRef(null)

  return (
    <HashRouter>
      <ConversationAppInner apiRef={apiRef} />
    </HashRouter>
  )
}

/**
 * Inner component that has access to router hooks
 */
const ConversationAppInner = ({ apiRef }) => {
  const navigate = useNavigate()

  const handleNotificationNavigate = useCallback((conversationId) => {
    // Navigate to the conversation
    navigate(`/conversations/${conversationId}`)
  }, [navigate])

  // Default conversation UUID for the demo
  const defaultConversationId = 'c9f2e8d1-3b4a-5c6d-7e8f-9a0b1c2d3e4f'

  return (
    <div>
      {/* Topic navigation bar - outside conversation container */}
      <TopicNav topics={TOPICS} />

      {/* Routed conversation view */}
      <Routes>
        <Route path="/" element={<Navigate to={`/conversations/${defaultConversationId}`} replace />} />
        <Route path="/conversations/:uuid" element={<ConversationView apiRef={apiRef} />} />
      </Routes>

      {/* Background notifications for subscribed conversations */}
      <BackgroundNotification onNavigate={handleNotificationNavigate} />
    </div>
  )
}

// Setup global API placeholder for before mount
if (!window.ReplicateConversation) {
  window._replicateConversationReadyCallbacks = []
  window.ReplicateConversation = {
    onReady: (callback) => {
      window._replicateConversationReadyCallbacks.push(callback)
    },
  }
}

// Mount function
const mount = () => {
  const container = document.querySelector('[data-conversation-app]')
  if (!container) return

  const root = ReactDOM.createRoot(container)
  root.render(<ConversationApp />)
}

if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', mount)
} else {
  mount()
}

export default ConversationApp
export { TOPICS }