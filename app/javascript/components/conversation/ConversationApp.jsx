import React, { useEffect, useRef, useCallback } from 'react'
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

/**
 * ConversationView - renders a conversation for a specific topic
 * Exposes the conversation API globally for demo streaming
 */
const ConversationView = ({ apiRef }) => {
  const { topic } = useParams()
  const navigate = useNavigate()
  const currentTopic = TOPICS.find(t => t.code === topic) || TOPICS[0]

  const {
    messages,
    isTyping,
    addMessage,
    updateMessage,
    removeMessage,
    clear,
    setTyping,
    sendUserMessage,
  } = useConversation({ conversationId: null }) // No ActionCable for demo

  // Expose API globally for external streaming
  useEffect(() => {
    const api = {
      addMessage,
      updateMessage,
      removeMessage,
      clear,
      setTyping,
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
  }, [addMessage, updateMessage, removeMessage, clear, setTyping, messages, isTyping, apiRef])

  // Handle topic change from dropdown
  const handleTopicChange = useCallback((newTopic) => {
    navigate(`/${newTopic.code}`)
  }, [navigate])

  // Handle message selection (for multiple choice, etc)
  const handleSelect = useCallback((messageId, optionId) => {
    updateMessage(messageId, {
      metadata: {
        ...messages.find(m => m.id === messageId)?.metadata,
        selectedId: optionId
      }
    })
  }, [updateMessage, messages])

  return (
    <Conversation
      messages={messages}
      isTyping={isTyping}
      onSend={sendUserMessage}
      onSelect={handleSelect}
      topics={TOPICS}
      currentTopic={currentTopic}
      onTopicChange={handleTopicChange}
      className="min-h-[500px]"
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

  return (
    <div>
      {/* Topic navigation bar - outside conversation container */}
      <TopicNav topics={TOPICS} />

      {/* Routed conversation view */}
      <Routes>
        <Route path="/" element={<Navigate to="/networking" replace />} />
        <Route path="/:topic" element={<ConversationView apiRef={apiRef} />} />
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