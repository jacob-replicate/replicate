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
 * @returns {Object} Conversation state and methods
 */
export function useConversation({ conversationId, autoSubscribe = true } = {}) {
  const [messages, setMessages] = useState([])
  const [isTyping, setIsTyping] = useState(false)
  const [isConnected, setIsConnected] = useState(false)
  const isSubscribedRef = useRef(false)

  // Add a message to the conversation
  const addMessage = useCallback((msgPartial) => {
    const message = {
      id: msgPartial.id || generateId(),
      content: msgPartial.content || '',
      author: msgPartial.author || { name: 'Unknown' },
      timestamp: msgPartial.timestamp || new Date(),
      isSystem: msgPartial.isSystem ?? true,
      type: msgPartial.type || 'text',
      metadata: msgPartial.metadata || {},
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

  // Send user message via ConversationManager
  const sendUserMessage = useCallback(async (content) => {
    // Add message locally immediately
    const messageId = addMessage({
      content,
      author: { name: 'You', avatar: null },
      isSystem: false,
      type: 'text',
    })

    // Send to backend if we have a conversation ID
    if (conversationId) {
      try {
        await conversationManager.send(conversationId, content)
      } catch (e) {
        console.error('[useConversation] Failed to send message:', e)
        // Could update message state to show error
      }
    }

    return messageId
  }, [addMessage, conversationId])

  // Subscribe to ActionCable via ConversationManager
  useEffect(() => {
    if (!conversationId || !autoSubscribe) return

    // Mark this conversation as active
    conversationManager.setActive(conversationId)

    // Subscribe or update callbacks
    if (!conversationManager.isSubscribed(conversationId)) {
      conversationManager.subscribe(conversationId, {
        onMessage: (message) => {
          addMessage({
            id: message.id,
            content: message.content,
            author: message.author,
            isSystem: message.is_system,
            type: message.message_type || 'text',
            metadata: message.metadata,
          })
        },
        onTyping: setTypingIndicator,
        onConnected: () => setIsConnected(true),
        onDisconnected: () => setIsConnected(false),
      })
      isSubscribedRef.current = true
    } else {
      // Update callbacks for existing subscription
      conversationManager.updateCallbacks(conversationId, {
        onMessage: (message) => {
          addMessage({
            id: message.id,
            content: message.content,
            author: message.author,
            isSystem: message.is_system,
            type: message.message_type || 'text',
            metadata: message.metadata,
          })
        },
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
    sendUserMessage,
  }
}

export default useConversation