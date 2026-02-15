import { useState, useCallback, useRef, useEffect } from 'react'
import conversationManager from '../lib/ConversationManager'

// Generate unique IDs
const generateId = () => `msg_${Date.now()}_${Math.random().toString(36).slice(2, 9)}`

/**
 * Hook for managing conversation state with multi-subscription support
 *
 * @param {Object} options
 * @param {string} options.conversationId - UUID for the conversation (for ActionCable)
 * @param {boolean} options.autoSubscribe - Automatically subscribe to ActionCable (default: true)
 * @param {number} options.initialSequence - Starting sequence number (default: 0)
 * @returns {Object} Conversation state and methods
 */
export function useConversation({ conversationId, autoSubscribe = true, initialSequence = 0 } = {}) {
  const [messages, setMessages] = useState([])
  const [isTyping, setIsTyping] = useState(false)
  const [isConnected, setIsConnected] = useState(false)
  const isSubscribedRef = useRef(false)

  // Sequence tracking for out-of-order message handling
  const messageQueueRef = useRef({})
  const expectedSequenceRef = useRef(initialSequence)

  // Add a message to the conversation
  const addMessage = useCallback((msgPartial) => {
    const message = {
      ...msgPartial,
      id: msgPartial.id || generateId(),
      author: msgPartial.author || { name: 'Unknown' },
      timestamp: msgPartial.timestamp || new Date(),
      isSystem: msgPartial.isSystem ?? false,
    }
    setMessages(prev => [...prev, message])
    return message.id
  }, [])

  // Update an existing message
  const updateMessage = useCallback((messageId, updates) => {
    setMessages(prev => prev.map(msg =>
      msg.id === messageId ? { ...msg, ...updates } : msg
    ))
  }, [])

  // Remove a message
  const removeMessage = useCallback((messageId) => {
    setMessages(prev => prev.filter(msg => msg.id !== messageId))
  }, [])

  // Clear all messages
  const clear = useCallback(() => {
    setMessages([])
    setIsTyping(false)
    // Reset sequence tracking
    messageQueueRef.current = {}
    expectedSequenceRef.current = initialSequence
  }, [initialSequence])

  // Set expected sequence (useful when loading existing conversations)
  const setExpectedSequence = useCallback((seq) => {
    expectedSequenceRef.current = seq
  }, [])

  // Set typing indicator
  // Accepts: setTyping(false), setTyping(true), setTyping(authorObject), setTyping(true, authorObject)
  const setTypingIndicator = useCallback((typingOrAuthor, author = null) => {
    if (typingOrAuthor === false) {
      setIsTyping(false)
    } else if (typeof typingOrAuthor === 'object' && typingOrAuthor !== null) {
      // Called with just author object: setTyping({ name: 'maya', avatar: '...' })
      setIsTyping(typingOrAuthor)
    } else if (typingOrAuthor === true && author) {
      // Called with (true, author)
      setIsTyping(author)
    } else {
      // Called with just true
      setIsTyping(true)
    }
  }, [])

  // Send user message to server
  // Server assigns ID and sequence, message comes back via normal message flow
  const sendUserMessage = useCallback(async (content) => {
    // Demo mode: use global API directly (when no conversationId)
    if (!conversationId && window.ReplicateConversation) {
      const api = window.ReplicateConversation
      const currentMessages = api.getMessages?.() || []

      // Get next sequence from existing messages
      const maxSeq = currentMessages.reduce((max, m) => Math.max(max, m.sequence ?? 0), 0)

      const message = {
        id: `msg_${Date.now()}_${Math.random().toString(36).slice(2, 9)}`,
        sequence: maxSeq + 1,
        author: { name: 'You', avatar: '/jacob-square.jpg' },
        created_at: new Date().toISOString(),
        components: [{ type: 'text', content }],
      }

      // Add message via the global API (simulates server broadcast)
      api.addMessage?.(message)
      return
    }

    // Real mode: send to server via ConversationManager
    if (conversationId) {
      try {
        await conversationManager.send(conversationId, content)
      } catch (e) {
        console.error('[useConversation] Failed to send message:', e)
      }
    }
  }, [conversationId])

  // Subscribe to ActionCable via ConversationManager
  useEffect(() => {
    if (!conversationId || !autoSubscribe) return

    // Mark this conversation as active
    conversationManager.setActive(conversationId)

    // Handler for incoming messages (includes sequence support)
    const handleMessage = (message) => {
      addMessage({
        id: message.id,
        content: message.content,
        author: message.author,
        isSystem: message.is_system,
        type: message.message_type || message.type || 'text',
        metadata: message.metadata,
        sequence: message.sequence, // Pass sequence for ordering
      })
    }

    // Subscribe or update callbacks
    if (!conversationManager.isSubscribed(conversationId)) {
      conversationManager.subscribe(conversationId, {
        onMessage: handleMessage,
        onTyping: setTypingIndicator,
        onConnected: () => setIsConnected(true),
        onDisconnected: () => setIsConnected(false),
      })
      isSubscribedRef.current = true
    } else {
      // Update callbacks for existing subscription
      conversationManager.updateCallbacks(conversationId, {
        onMessage: handleMessage,
        onTyping: setTypingIndicator,
        onConnected: () => setIsConnected(true),
        onDisconnected: () => setIsConnected(false),
      })
    }

    // Note: We intentionally do NOT unsubscribe on unmount
    // This allows background notifications to continue
    return () => {
      // Clear active status when unmounting
      if (conversationManager.activeConversationId === conversationId) {
        conversationManager.setActive(null)
      }
    }
  }, [conversationId, autoSubscribe, addMessage, setTypingIndicator])

  return {
    // State
    messages,
    isTyping,
    isConnected,

    // Methods
    addMessage,
    updateMessage,
    removeMessage,
    clear,
    setTyping: setTypingIndicator,
    setExpectedSequence,
    sendUserMessage,
  }
}

export default useConversation