import React, { useEffect, useRef, useCallback, useState } from 'react'
import ReactDOM from 'react-dom/client'
import { BrowserRouter, Routes, Route, useParams, useNavigate, useLocation } from 'react-router-dom'
import Conversation from './Conversation'
import ChannelSwitcher from './ChannelSwitcher'
import SecurityPage from './SecurityPage'
import PrivacyPage from './PrivacyPage'
import { ConversationProvider, useConversationContext } from './ConversationContext'
import { NotificationProvider, useNotifications } from './NotificationContext'
import useConversation from '../../hooks/useConversation'
const DEFAULT_CHANNEL_ID = 'dns'


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
  const conversationRef = useRef(null)
  const { conversations, updateConversation } = useConversationContext()

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

  // Use refs for functions to avoid stale closures
  const addMessageRef = useRef(addMessage)
  const setTypingRef = useRef(setTyping)
  const updateMessageRef = useRef(updateMessage)

  useEffect(() => {
    addMessageRef.current = addMessage
    setTypingRef.current = setTyping
    updateMessageRef.current = updateMessage
  })

  const sleep = (ms) => new Promise(resolve => setTimeout(resolve, ms))

  /**
   * Load all messages instantly (for initial page load)
   * No typing indicators, no delays — just populate the conversation
   */
  const loadMessages = useCallback((messagesToLoad) => {
    const sorted = [...messagesToLoad].sort((a, b) => (a.sequence ?? 0) - (b.sequence ?? 0))
    for (const message of sorted) {
      addMessageRef.current(message)
    }
    setIsLoaded(true)
  }, [])

  /**
   * Stream a batch of messages with typing indicators and delays.
   * For each message:
   *   1. Show typing indicator for the author
   *   2. After a brief delay, add the full message (all components at once)
   *   3. Pause before the next message
   *
   * Multiple-choice messages are added instantly (no typing indicator).
   */
  const streamMessages = useCallback(async (messagesToStream) => {
    for (const message of messagesToStream) {
      const isMCQ = message.components?.some(c => c.type === 'multiple_choice')

      if (isMCQ) {
        addMessageRef.current(message)
      } else {
        // Show typing indicator
        setTypingRef.current(message.author || true)
        await sleep(600)

        // Add the full message and clear typing
        setTypingRef.current(false)
        addMessageRef.current(message)

        // Pause between messages
        await sleep(400)
      }
    }
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
    window.Conversation = {
      ...api,
      onReady: (callback) => {
        // Already ready, call immediately
        callback(api)
      },
    }

    // Fire any queued onReady callbacks
    if (window._ConversationReadyCallbacks) {
      window._ConversationReadyCallbacks.forEach(cb => cb(api))
      window._ConversationReadyCallbacks = []
    }

    return () => {
      // Don't clean up global API - let it persist
    }
  }, [addMessage, updateMessage, removeMessage, clear, setTyping, setExpectedSequence, setChannelName, messages, isTyping, isLoaded, apiRef, streamMessages, loadMessages])

  // Load conversation when component mounts and conversations are available
  const hasLoadedRef = useRef(false)
  useEffect(() => {
    if (!uuid || hasLoadedRef.current) return
    setChannelName('#' + uuid)

    // Check if this is a real API-backed channel
    const channel = conversations.find(c => c.id === uuid)

    // Conversations haven't loaded from the API yet — wait
    if (conversations.length === 0) return

    hasLoadedRef.current = true

    if (channel?.templateId) {
      fetch(`/api/conversations/${channel.templateId}`, { credentials: 'include' })
        .then(res => res.ok ? res.json() : Promise.reject(res))
        .then(data => {
          const rawMsgs = data.messages || []
          const msgs = rawMsgs.map(m => ({
            id: m.id,
            sequence: m.sequence,
            author: { name: m.author_name, avatar: m.author_avatar },
            isSystem: m.is_system,
            created_at: m.created_at,
            components: m.components || [],
          }))
          loadMessages(msgs)

          const lastMsgId = rawMsgs[rawMsgs.length - 1]?.id || null
          updateConversation(channel.uuid, {
            forkedId: data.id,
            messages: rawMsgs,
            messagesLoading: 'complete',
            lastReadMessageId: lastMsgId,
          })
        })
        .catch(err => {
          console.error('[ConversationView] API fetch failed:', err)
        })
    }
  }, [uuid, conversations])

  // Handle message selection (for multiple choice, etc)
  // Removes the system prompt, shows typing indicator, then sends user's message
  const handleSelect = useCallback(async (messageId, optionId, optionText) => {
    // Remove the system prompt immediately
    removeMessage(messageId)

    // Show typing indicator for "You"
    setTyping({ name: 'You', avatar: '/user-profile.jpg' })

    // Wait a moment (simulates typing)
    await new Promise(resolve => setTimeout(resolve, 600))

    // Clear typing indicator
    setTyping(false)

    // Send the user's response (will appear as a normal message)
    if (optionText) {
      sendUserMessage(optionText)
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
      conversationId={uuid}
      autoFocusInput={true}
    />
  )
}

/**
 * ConversationApp - Root component with routing
 */
const ConversationApp = () => {
  const apiRef = useRef(null)

  return (
    <ConversationProvider initialConversations={[]}>
      <BrowserRouter>
        <ConversationBootstrap />
        <ConversationAppInnerWithNotifications apiRef={apiRef} />
      </BrowserRouter>
    </ConversationProvider>
  )
}

const ACRONYMS = new Set(['dns', 'iam'])

const topicToName = (topic) =>
  topic.split('-').map(w => ACRONYMS.has(w) ? w.toUpperCase() : w.charAt(0).toUpperCase() + w.slice(1)).join(' ')

/**
 * ConversationBootstrap - fetches template conversations from the API on mount
 * and populates the context. Runs once.
 */
const ConversationBootstrap = () => {
  const { setConversationsDirect } = useConversationContext()

  useEffect(() => {
    fetch('/api/conversations', { credentials: 'include' })
      .then(res => res.ok ? res.json() : Promise.reject(res))
      .then(templates => {
        const channels = templates.map(t => ({
          uuid: t.id,
          id: t.topic,
          name: topicToName(t.topic),
          templateId: t.id,
          lastReadMessageId: t.last_read_message_id,
          messages: [],
          messagesLoading: 'idle',
        }))
        setConversationsDirect(channels)
      })
      .catch(err => {
        console.error('[ConversationBootstrap] Failed to load conversations:', err)
      })
  }, [setConversationsDirect])

  return null
}

/**
 * Wrapper that provides NotificationProvider with navigate access
 */
const ConversationAppInnerWithNotifications = ({ apiRef }) => {
  const navigate = useNavigate()

  const handleNotificationClick = useCallback((channelId) => {
    navigate(`/${channelId}`)
  }, [navigate])

  return (
    <NotificationProvider onNotificationClick={handleNotificationClick}>
      <ConversationAppInner apiRef={apiRef} />
    </NotificationProvider>
  )
}

/**
 * Inner component that has access to router hooks
 */
const ConversationAppInner = ({ apiRef }) => {
  const navigate = useNavigate()
  const location = useLocation()
  const { uuid } = useParams() || {}

  // Get conversations from context instead of local state
  const { conversations, findConversation, markAsRead, updateConversation } = useConversationContext()
  const { showNotification } = useNotifications()

  // Initialize activeChannelId from URL path (e.g., /dns -> dns)
  const getChannelIdFromPath = useCallback((pathname) => {
    const pathChannel = pathname.replace(/^\//, '').split('/')[0]
    if (!pathChannel || pathChannel === '') return DEFAULT_CHANNEL_ID
    // If conversations are loaded, validate against them; otherwise trust the path
    if (conversations.length > 0) {
      const isKnownChannel = conversations.some(c => c.id === pathChannel)
      return isKnownChannel ? pathChannel : DEFAULT_CHANNEL_ID
    }
    return pathChannel
  }, [conversations])

  // Get initial channel from URL
  const getInitialChannelId = () => {
    const pathChannel = location.pathname.replace(/^\//, '').split('/')[0]
    return pathChannel || DEFAULT_CHANNEL_ID
  }

  const [activeChannelId, setActiveChannelId] = useState(getInitialChannelId)

  // Trickle in fake unread notifications after page load
  useEffect(() => {
    // Channels that can receive fake unreads (not the active one, has messages, and is currently "read")
    const getEligibleChannels = () => {
      return conversations
        .filter(c => {
          if (c.id === activeChannelId) return false
          const lastMessageId = c.messages?.[c.messages.length - 1]?.id
          if (!lastMessageId) return false
          // Only eligible if currently read (lastReadMessageId matches last message)
          return c.lastReadMessageId === lastMessageId
        })
    }

    // Fake message previews for notifications
    const fakeMessages = [
      { avatar: '/profile-photo-1.jpg', author: 'alex', message: 'seeing connection pool exhaustion on the primary — pg_stat_activity shows 200+ idle in transaction' },
      { avatar: '/profile-photo-2.jpg', author: 'daniel', message: 'replica lag spiked to 45s after that schema migration, might need to throttle the backfill' },
      { avatar: '/profile-photo-3.jpg', author: 'maya', message: 'getting OOM kills on the worker pods, heap dumps show a leak in the redis connection factory' },
    ]

    // Schedule unread notifications with varying delays
    const delays = [
      2000 + Math.random() * 1000,   // 2-3s
      4500 + Math.random() * 1500,   // 4.5-6s
      7000 + Math.random() * 2000,   // 7-9s
    ]

    const timeoutIds = []

    delays.forEach((delay, index) => {
      const timeoutId = setTimeout(() => {
        const eligible = getEligibleChannels()
        if (eligible.length === 0) return

        // Pick a random channel from eligible ones
        const randomChannel = eligible[Math.floor(Math.random() * eligible.length)]
        // Set lastReadMessageId to null to mark as unread
        updateConversation(randomChannel.uuid, { lastReadMessageId: null })

        // Show notification popup
        const fake = fakeMessages[index % fakeMessages.length]
        showNotification({
          avatar: fake.avatar,
          title: fake.author,
          channelName: randomChannel.name,
          message: fake.message,
          channelId: randomChannel.id,
        })
      }, delay)
      timeoutIds.push(timeoutId)
    })

    return () => {
      timeoutIds.forEach(id => clearTimeout(id))
    }
  }, []) // Only run once on mount

  // Update document title when channel changes
  useEffect(() => {
    const channel = conversations.find(c => c.id === activeChannelId)
    const channelName = channel?.name || activeChannelId
    // Capitalize first letter
    const formattedName = channelName.charAt(0).toUpperCase() + channelName.slice(1)
    document.title = `Invariant: ${formattedName}`
  }, [activeChannelId, conversations])

  // Persist last visited channel to localStorage
  useEffect(() => {
    if (activeChannelId) {
      localStorage.setItem('lastChannelId', activeChannelId)
    }
  }, [activeChannelId])

  // Sync activeChannelId when URL changes (e.g., direct navigation to /dns)
  useEffect(() => {
    const channelFromPath = getChannelIdFromPath(location.pathname)
    if (channelFromPath !== activeChannelId) {
      setActiveChannelId(channelFromPath)
    }
  }, [location.pathname, getChannelIdFromPath, activeChannelId])

  const handleChannelSelect = useCallback((channelId) => {
    setActiveChannelId(channelId)
    navigate(`/${channelId}`)

    const channel = conversations.find(c => c.id === channelId)

    if (channel?.templateId) {
      // Fork via show endpoint and load messages
      fetch(`/api/conversations/${channel.templateId}`, { credentials: 'include' })
        .then(res => res.ok ? res.json() : Promise.reject(res))
        .then(data => {
          const msgs = data.messages || []
          const lastMsgId = msgs[msgs.length - 1]?.id || null

          updateConversation(channel.uuid, {
            forkedId: data.id,
            messages: msgs,
            messagesLoading: 'complete',
            lastReadMessageId: lastMsgId,
          })
        })
        .catch(err => {
          console.error('[handleChannelSelect] API fetch failed:', err)
        })
    }
  }, [navigate, conversations, markAsRead, updateConversation])

  // Expose navigate function globally for demo script
  useEffect(() => {
    window.Conversation = {
      ...window.Conversation,
      navigate: (path) => navigate(path),
    }
  }, [navigate])

  return (
    <div className="h-full w-full">
      <ChannelSwitcher
        channels={conversations}
        activeChannelId={activeChannelId}
        onChannelSelect={handleChannelSelect}
      >
        {/* Routed conversation view */}
        <Routes>
          <Route path="/" element={<RootRedirect />} />
          <Route path="/security" element={<SecurityPage />} />
          <Route path="/privacy" element={<PrivacyPage />} />
          <Route
            path="/:uuid"
            element={<ConversationViewWrapper apiRef={apiRef} />}
          />
        </Routes>
      </ChannelSwitcher>
    </div>
  )
}

/**
 * Root redirect - navigates to last visited channel (from localStorage) or default
 */
const RootRedirect = () => {
  const navigate = useNavigate()
  const { conversations } = useConversationContext()

  useEffect(() => {
    if (conversations.length === 0) return // wait for bootstrap
    const lastChannel = localStorage.getItem('lastChannelId')
    const isValidChannel = lastChannel && conversations.some(c => c.id === lastChannel)
    const channelToUse = isValidChannel ? lastChannel : DEFAULT_CHANNEL_ID
    navigate(`/${channelToUse}`, { replace: true })
  }, [navigate, conversations])

  return (
    <div className="flex items-center justify-center h-64 text-zinc-400">
      Loading...
    </div>
  )
}

// Setup global API placeholder for before mount
if (!window.Conversation) {
  window._ConversationReadyCallbacks = []
  window.Conversation = {
    onReady: (callback) => {
      window._ConversationReadyCallbacks.push(callback)
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