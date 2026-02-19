import React, { createContext, useContext, useState, useCallback, useEffect } from 'react'

/**
 * ConversationContext - shared state for the conversation system
 *
 * Shape:
 * - currentOwner: { type, id, name?, avatar?, email? }
 * - conversations: array of conversation objects with nested messages
 * - isDarkMode, sidebarCollapsed: UI preferences (synced to localStorage)
 * - actions: markAsRead, fetchConversation, sendMessage
 *
 * Note: activeConversationId comes from router (useParams), not context
 */

const ConversationContext = createContext(null)

const STORAGE_KEYS = {
  IS_DARK_MODE: 'conversation_isDarkMode',
  SIDEBAR_COLLAPSED: 'conversation_sidebarCollapsed',
}

/**
 * Load a value from localStorage with a default
 */
const loadFromStorage = (key, defaultValue) => {
  try {
    const stored = localStorage.getItem(key)
    if (stored === null) return defaultValue
    return JSON.parse(stored)
  } catch {
    return defaultValue
  }
}

/**
 * Save a value to localStorage
 */
const saveToStorage = (key, value) => {
  try {
    localStorage.setItem(key, JSON.stringify(value))
  } catch {
    // localStorage might be full or disabled
  }
}

/**
 * ConversationProvider - wraps app and provides conversation state
 *
 * @param {Object} props
 * @param {Object} props.initialOwner - Initial owner object (optional)
 * @param {Array} props.initialConversations - Initial conversations array (optional, for demos)
 * @param {React.ReactNode} props.children
 */
export function ConversationProvider({
  initialOwner = null,
  initialConversations = [],
  children
}) {
  // Owner - could be User or Session
  const [currentOwner, setCurrentOwner] = useState(initialOwner)

  // Conversations with nested messages
  const [conversations, setConversations] = useState(() =>
    initialConversations.map(c => ({
      ...c,
      messages: c.messages || [],
      messagesLoading: c.messagesLoading || 'idle', // 'idle' | 'loading' | 'partial' | 'complete'
    }))
  )

  // UI Preferences - synced to localStorage
  const [isDarkMode, setIsDarkModeState] = useState(() => {
    // First check DOM (may be set by server or previous session)
    if (typeof document !== 'undefined' && document.documentElement.classList.contains('dark')) {
      return true
    }
    // Then check localStorage
    const stored = loadFromStorage(STORAGE_KEYS.IS_DARK_MODE, null)
    if (stored !== null) return stored
    // Default to false
    return false
  })
  const [sidebarCollapsed, setSidebarCollapsedState] = useState(() =>
    loadFromStorage(STORAGE_KEYS.SIDEBAR_COLLAPSED, false)
  )

  // Persist UI preferences and sync to DOM
  const setIsDarkMode = useCallback((value) => {
    setIsDarkModeState(value)
    saveToStorage(STORAGE_KEYS.IS_DARK_MODE, value)
    // Sync to DOM
    if (typeof document !== 'undefined') {
      if (value) {
        document.documentElement.classList.add('dark')
      } else {
        document.documentElement.classList.remove('dark')
      }
    }
  }, [])

  const setSidebarCollapsed = useCallback((value) => {
    setSidebarCollapsedState(value)
    saveToStorage(STORAGE_KEYS.SIDEBAR_COLLAPSED, value)
  }, [])

  /**
   * Find a conversation by UUID
   */
  const findConversation = useCallback((uuid) => {
    return conversations.find(c => c.uuid === uuid)
  }, [conversations])

  /**
   * Update a specific conversation
   */
  const updateConversation = useCallback((uuid, updates) => {
    setConversations(prev => prev.map(c =>
      c.uuid === uuid ? { ...c, ...updates } : c
    ))
  }, [])

  /**
   * Fetch conversations list from API
   */
  const fetchConversations = useCallback(async () => {
    try {
      const response = await fetch('/api/conversations', { credentials: 'include' })
      if (!response.ok) throw new Error('Failed to fetch conversations')
      const data = await response.json()

      setConversations(data.map(c => ({
        ...c,
        messages: [],
        messagesLoading: 'idle',
      })))
    } catch (error) {
      console.error('[ConversationContext] fetchConversations error:', error)
      throw error
    }
  }, [])

  /**
   * Fetch a single conversation with messages
   */
  const fetchConversation = useCallback(async (uuid) => {
    // Mark as loading
    updateConversation(uuid, { messagesLoading: 'loading' })

    try {
      const response = await fetch(`/api/conversations/${uuid}`, { credentials: 'include' })
      if (!response.ok) throw new Error('Failed to fetch conversation')
      const data = await response.json()

      updateConversation(uuid, {
        ...data,
        messages: data.messages || [],
        messagesLoading: 'complete',
      })
    } catch (error) {
      console.error('[ConversationContext] fetchConversation error:', error)
      updateConversation(uuid, { messagesLoading: 'idle' })
      throw error
    }
  }, [updateConversation])

  /**
   * Mark a conversation as read
   * Optimistic update - sets unreadCount to 0 immediately
   */
  const markAsRead = useCallback(async (uuid) => {
    const conversation = findConversation(uuid)
    if (!conversation || conversation.unreadCount === 0) return

    // Get the last message ID for the API call
    const lastMessage = conversation.messages?.[conversation.messages.length - 1]
    const lastReadMessageId = lastMessage?.id

    // Optimistic update
    updateConversation(uuid, { unreadCount: 0, lastReadMessageId })

    try {
      await fetch(`/api/conversations/${uuid}`, {
        method: 'PATCH',
        credentials: 'include',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ last_read_message_id: lastReadMessageId }),
      })
    } catch (error) {
      console.error('[ConversationContext] markAsRead error:', error)
      // Could revert the optimistic update here if needed
    }
  }, [findConversation, updateConversation])

  /**
   * Send a message to a conversation
   */
  const sendMessage = useCallback(async (uuid, content) => {
    try {
      const response = await fetch(`/api/conversations/${uuid}/messages`, {
        method: 'POST',
        credentials: 'include',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ content }),
      })

      if (!response.ok) throw new Error('Failed to send message')
      const message = await response.json()

      // Append message to conversation
      setConversations(prev => prev.map(c =>
        c.uuid === uuid
          ? { ...c, messages: [...c.messages, message] }
          : c
      ))

      return message
    } catch (error) {
      console.error('[ConversationContext] sendMessage error:', error)
      throw error
    }
  }, [])

  /**
   * Add a message locally (for demos/optimistic updates)
   */
  const addMessageLocally = useCallback((uuid, message) => {
    setConversations(prev => prev.map(c =>
      c.uuid === uuid
        ? { ...c, messages: [...c.messages, message] }
        : c
    ))
  }, [])

  /**
   * Update a message locally (for demos/streaming)
   */
  const updateMessageLocally = useCallback((uuid, messageId, updates) => {
    setConversations(prev => prev.map(c =>
      c.uuid === uuid
        ? {
            ...c,
            messages: c.messages.map(m =>
              m.id === messageId ? { ...m, ...updates } : m
            )
          }
        : c
    ))
  }, [])

  /**
   * Set conversations directly (for demos)
   */
  const setConversationsDirect = useCallback((newConversations) => {
    setConversations(newConversations.map(c => ({
      ...c,
      messages: c.messages || [],
      messagesLoading: c.messagesLoading || 'idle',
    })))
  }, [])

  const value = {
    // Owner
    currentOwner,
    setCurrentOwner,

    // Conversations
    conversations,
    findConversation,
    fetchConversations,
    fetchConversation,

    // Actions
    markAsRead,
    sendMessage,

    // Local mutations (for demos)
    addMessageLocally,
    updateMessageLocally,
    setConversationsDirect,
    updateConversation,

    // UI Preferences
    isDarkMode,
    setIsDarkMode,
    sidebarCollapsed,
    setSidebarCollapsed,
  }

  return (
    <ConversationContext.Provider value={value}>
      {children}
    </ConversationContext.Provider>
  )
}

/**
 * Hook to access conversation context
 * Throws if used outside of ConversationProvider
 */
export function useConversationContext() {
  const context = useContext(ConversationContext)
  if (!context) {
    throw new Error('useConversationContext must be used within a ConversationProvider')
  }
  return context
}

/**
 * Hook to get a specific conversation by UUID
 * Returns the conversation object or undefined
 */
export function useConversationByUuid(uuid) {
  const { findConversation } = useConversationContext()
  return findConversation(uuid)
}

export default ConversationContext