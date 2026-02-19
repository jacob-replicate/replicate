import React, { useEffect, useRef, useCallback, useState } from 'react'
import ReactDOM from 'react-dom/client'
import { BrowserRouter, Routes, Route, useParams, useNavigate } from 'react-router-dom'
import Conversation from './Conversation'
import BackgroundNotification from './BackgroundNotification'
import ChannelSwitcher from './ChannelSwitcher'
import useConversation from '../../hooks/useConversation'
import {
  orchestrateDemoResponse,
  orchestrateFollowUpResponse,
  isPrimaryOption,
  isFollowUpOption
} from '../../demos/demoOrchestrator'
import { loadDemo } from '../../demos/demoRegistry'
import { DEMO_CHANNELS, DEMO_SECTIONS, DEFAULT_CHANNEL_ID } from '../../demos/channelData'

// Timing constants for message streaming
const TYPING_DURATION = 600
const MIN_GAP_BETWEEN_AUTHORS = 400

const sleep = (ms) => new Promise(resolve => setTimeout(resolve, ms))

/**
 * Wrapper that forces ConversationView to remount when UUID changes
 */
const ConversationViewWrapper = ({ apiRef }) => {
  const { uuid } = useParams()
  return <ConversationView key={uuid} apiRef={apiRef} />
}

/**
 * ConversationView - renders a conversation for a specific UUID
 * Exposes the conversation API globally for demo streaming
 */
const ConversationView = ({ apiRef }) => {
  const { uuid } = useParams()
  const navigate = useNavigate()
  const [channelName, setChannelName] = useState('#ops-alerts')
  const [isLoaded, setIsLoaded] = useState(false)

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

    // Track current counts for each reaction
    const currentCounts = finalReactions.map(() => 0)

    // Helper to get reactions with count >= 1 only
    const getVisibleReactions = () => {
      return finalReactions
        .map((r, i) => ({ ...r, count: currentCounts[i] }))
        .filter(r => r.count >= 1)
    }

    setTimeout(() => {
      // For each reaction, tick up to final count with random intervals
      finalReactions.forEach((reaction, reactionIndex) => {
        let tickCount = 0
        const tickUp = () => {
          tickCount++
          currentCounts[reactionIndex] = tickCount

          // Only show reactions with count >= 1
          updateMessageRef.current(messageId, {
            reactions: getVisibleReactions()
          })

          if (tickCount < reaction.count) {
            // 1-3 seconds between ticks
            setTimeout(tickUp, 1000 + Math.random() * 2000)
          }
        }

        // Stagger start of each reaction type (0-2 seconds)
        setTimeout(tickUp, Math.random() * 2000)
      })
    }, baseDelay)
  }, [])

  // Track thread reply queues per parent message (for staggered streaming)
  const threadQueuesRef = useRef(new Map()) // parentId -> { queue: [], processing: boolean }

  /**
   * Process thread reply queue for a parent message
   * Streams replies in order with delays between them
   */
  const processThreadQueue = useCallback((parentId) => {
    const queueData = threadQueuesRef.current.get(parentId)
    if (!queueData || queueData.processing || queueData.queue.length === 0) return

    queueData.processing = true

    const processNext = () => {
      const queueData = threadQueuesRef.current.get(parentId)
      if (!queueData || queueData.queue.length === 0) {
        queueData.processing = false
        return
      }

      // Get next reply (already sorted by sequence)
      const reply = queueData.queue.shift()
      addMessageRef.current(reply)

      // If more replies, schedule next one with delay (1-3 seconds)
      if (queueData.queue.length > 0) {
        setTimeout(processNext, 1000 + Math.random() * 2000)
      } else {
        queueData.processing = false
      }
    }

    // Start processing after initial delay (0.5-1.5 seconds)
    setTimeout(processNext, 500 + Math.random() * 1000)
  }, [])

  /**
   * Queue a thread reply for staggered streaming
   * Maintains order by sequence within each parent's queue
   */
  const queueThreadReply = useCallback((message) => {
    const parentId = message.parent_message_id

    if (!threadQueuesRef.current.has(parentId)) {
      threadQueuesRef.current.set(parentId, { queue: [], processing: false })
    }

    const queueData = threadQueuesRef.current.get(parentId)

    // Insert in order by sequence (global monotonic integer)
    const sequence = message.sequence ?? 0
    const insertIndex = queueData.queue.findIndex(m => (m.sequence ?? 0) > sequence)

    if (insertIndex === -1) {
      queueData.queue.push(message)
    } else {
      queueData.queue.splice(insertIndex, 0, message)
    }

    // Start processing if not already
    processThreadQueue(parentId)
  }, [processThreadQueue])

  /**
   * Stream messages with typing indicators and delays
   * Shows typing indicator before each new message, then streams components
   *
   * Thread replies (messages with parent_message_id) are queued and streamed
   * with delays, but don't block the main conversation flow
   *
   * Reactions are animated asynchronously after the message appears
   */
  const streamMessages = useCallback(async (messagesToStream) => {
    for (const message of messagesToStream) {
      // Thread replies are queued for staggered streaming (non-blocking)
      if (message.parent_message_id) {
        queueThreadReply(message)
        continue
      }

      // Check if this is a channel_join message (no typing indicator needed)
      const isChannelJoin = message.components?.length === 1 &&
        message.components[0].type === 'channel_join'

      // Show typing indicator for this author (skip for channel_join)
      if (!isChannelJoin) {
        setTypingRef.current(message.author)
        await sleep(TYPING_DURATION)
        setTypingRef.current(false)
      }

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
  }, [animateReactions, queueThreadReply])

  /**
   * Load all messages instantly (for existing conversations)
   * No typing indicators, no delays, no animations - just populate the conversation
   * All messages (including thread replies) and reactions appear immediately at final state
   */
  const loadMessages = useCallback((messagesToLoad) => {
    console.log('[loadMessages] called with', messagesToLoad?.length, 'messages')
    console.log('[loadMessages] messagesToLoad:', messagesToLoad)
    // Sort by sequence to ensure correct order
    const sorted = [...messagesToLoad].sort((a, b) => {
      const seqA = a.components?.[0]?.sequence ?? 0
      const seqB = b.components?.[0]?.sequence ?? 0
      return seqA - seqB
    })

    console.log('[loadMessages] sorted messages:', sorted.length)
    // Add all messages instantly (including thread replies) with full reactions
    for (const message of sorted) {
      console.log('[loadMessages] adding message:', message.id)
      addMessageRef.current(message)
    }
    setIsLoaded(true)
  }, [])

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
      loadMessages,
      setChannelName,
      getMessages: () => messages,
      isTyping: () => isTyping,
      isLoaded: () => isLoaded,
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
  }, [addMessage, updateMessage, removeMessage, clear, setTyping, setExpectedSequence, setChannelName, messages, isTyping, isLoaded, apiRef, streamMessages, loadMessages])

  // Handle message selection (for multiple choice, etc)
  // Removes the system prompt, shows typing indicator, then sends user's message
  // Then orchestrates demo responses based on the selected option
  const handleSelect = useCallback(async (messageId, optionId, optionText) => {
    // Remove the system prompt immediately
    removeMessage(messageId)

    // Show typing indicator for "You"
    setTyping({ name: 'You', avatar: '/jacob-square.jpg' })

    // Wait a moment (simulates typing)
    await new Promise(resolve => setTimeout(resolve, 600))

    // Clear typing indicator
    setTyping(false)

    // Send the user's response (will appear as a normal message)
    if (optionText) {
      sendUserMessage(optionText)
    }

    // Orchestrate demo responses based on option type
    if (window.ReplicateConversation) {
      if (isPrimaryOption(optionId)) {
        // First-level option (a, b, c, d) - trigger engineer pushback + follow-up
        orchestrateDemoResponse(optionId, window.ReplicateConversation)
      } else if (isFollowUpOption(optionId)) {
        // Second-level option - trigger final response
        orchestrateFollowUpResponse(optionId, window.ReplicateConversation)
      }
    }
  }, [removeMessage, setTyping, sendUserMessage])

  return (
    <Conversation
      messages={messages}
      isTyping={isTyping}
      onSend={sendUserMessage}
      onSelect={handleSelect}
      channelName={channelName}
      variant="irc"
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
    <BrowserRouter>
      <ConversationAppInner apiRef={apiRef} />
    </BrowserRouter>
  )
}

/**
 * Inner component that has access to router hooks
 */
const ConversationAppInner = ({ apiRef }) => {
  const navigate = useNavigate()
  const { uuid } = useParams() || {}

  const [channels] = useState(DEMO_CHANNELS)
  const [activeChannelId, setActiveChannelId] = useState(DEFAULT_CHANNEL_ID)

  const handleChannelSelect = useCallback((channelId) => {
    console.log('[handleChannelSelect] called with channelId:', channelId)
    setActiveChannelId(channelId)
    console.log('[handleChannelSelect] navigating to:', `/conversations/${channelId}`)
    navigate(`/conversations/${channelId}`)

    console.log('[handleChannelSelect] calling loadDemo directly')
    loadDemo(channelId)
  }, [navigate])

  const handleNotificationNavigate = useCallback((conversationId) => {
    navigate(`/conversations/${conversationId}`)
  }, [navigate])

  // Expose navigate function globally for demo script
  useEffect(() => {
    window.ReplicateConversation = {
      ...window.ReplicateConversation,
      navigate: (path) => navigate(path),
    }
  }, [navigate])

  return (
    <div className="h-full w-full">
      <ChannelSwitcher
        channels={channels}
        sections={DEMO_SECTIONS}
        activeChannelId={activeChannelId}
        onChannelSelect={handleChannelSelect}
      >
        {/* Routed conversation view */}
        <Routes>
          <Route path="/" element={<RootRedirect />} />
          <Route
            path="/conversations/:uuid"
            element={<ConversationViewWrapper apiRef={apiRef} />}
          />
        </Routes>
      </ChannelSwitcher>

      {/* Background notifications for subscribed conversations */}
      <BackgroundNotification onNavigate={handleNotificationNavigate} />
    </div>
  )
}

/**
 * Root redirect - waits for demo script to navigate, or shows loading
 */
const RootRedirect = () => {
  return (
    <div className="flex items-center justify-center h-64 text-zinc-400">
      Loading conversation...
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