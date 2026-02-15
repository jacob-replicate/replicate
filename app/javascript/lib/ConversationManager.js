import consumer from '../channels/consumer'

/**
 * ConversationManager - manages multiple ActionCable subscriptions
 *
 * Users stay subscribed to conversations even after navigating away.
 * Background conversations can trigger notifications.
 */
class ConversationManager {
  constructor() {
    this.subscriptions = new Map() // conversationId -> { subscription, callbacks, messages }
    this.activeConversationId = null
    this.notificationCallbacks = new Set()
  }

  /**
   * Subscribe to a conversation
   * @param {string} conversationId - UUID of the conversation
   * @param {Object} callbacks - Event handlers
   * @param {Function} callbacks.onMessage - Called when message received
   * @param {Function} callbacks.onTyping - Called when typing indicator changes
   * @param {Function} callbacks.onConnected - Called when connected
   * @param {Function} callbacks.onDisconnected - Called when disconnected
   */
  subscribe(conversationId, callbacks = {}) {
    if (this.subscriptions.has(conversationId)) {
      // Update callbacks for existing subscription
      const existing = this.subscriptions.get(conversationId)
      existing.callbacks = { ...existing.callbacks, ...callbacks }
      return existing.subscription
    }

    const subscription = consumer.subscriptions.create(
      { channel: 'ConversationChannel', id: conversationId },
      {
        connected: () => {
          const sub = this.subscriptions.get(conversationId)
          if (sub?.callbacks.onConnected) {
            sub.callbacks.onConnected()
          }
        },
        disconnected: () => {
          const sub = this.subscriptions.get(conversationId)
          if (sub?.callbacks.onDisconnected) {
            sub.callbacks.onDisconnected()
          }
        },
        received: (data) => {
          this._handleReceived(conversationId, data)
        },
      }
    )

    this.subscriptions.set(conversationId, {
      subscription,
      callbacks,
      messages: [],
      isTyping: false,
    })

    return subscription
  }

  /**
   * Update callbacks for an existing subscription
   */
  updateCallbacks(conversationId, callbacks) {
    const sub = this.subscriptions.get(conversationId)
    if (sub) {
      sub.callbacks = { ...sub.callbacks, ...callbacks }
    }
  }

  /**
   * Unsubscribe from a conversation
   */
  unsubscribe(conversationId) {
    const sub = this.subscriptions.get(conversationId)
    if (sub) {
      sub.subscription.unsubscribe()
      this.subscriptions.delete(conversationId)
    }
  }

  /**
   * Mark a conversation as currently active (visible to user)
   */
  setActive(conversationId) {
    this.activeConversationId = conversationId
  }

  /**
   * Check if a conversation is currently active
   */
  isActive(conversationId) {
    return this.activeConversationId === conversationId
  }

  /**
   * Get all subscribed conversation IDs
   */
  getSubscribedIds() {
    return Array.from(this.subscriptions.keys())
  }

  /**
   * Check if subscribed to a conversation
   */
  isSubscribed(conversationId) {
    return this.subscriptions.has(conversationId)
  }

  /**
   * Register callback for background notifications
   */
  onBackgroundNotification(callback) {
    this.notificationCallbacks.add(callback)
    return () => this.notificationCallbacks.delete(callback)
  }

  /**
   * Handle incoming data from ActionCable
   */
  _handleReceived(conversationId, data) {
    const sub = this.subscriptions.get(conversationId)
    if (!sub) return

    const isBackground = !this.isActive(conversationId)

    switch (data.type) {
      case 'message':
        // Store message
        sub.messages.push(data.message)

        // Call conversation callback
        if (sub.callbacks.onMessage) {
          sub.callbacks.onMessage(data.message)
        }

        // Fire background notification if not active
        if (isBackground) {
          this._notifyBackground(conversationId, data.message)
        }
        break

      case 'typing':
        sub.isTyping = data.typing
        if (sub.callbacks.onTyping) {
          sub.callbacks.onTyping(data.typing)
        }
        break

      case 'update':
        // Message update (e.g., edit, reaction)
        if (sub.callbacks.onUpdate) {
          sub.callbacks.onUpdate(data.message)
        }
        break

      default:
        console.warn('[ConversationManager] Unknown message type:', data.type)
    }
  }

  /**
   * Fire background notification callbacks
   */
  _notifyBackground(conversationId, message) {
    for (const callback of this.notificationCallbacks) {
      try {
        callback({ conversationId, message })
      } catch (e) {
        console.error('[ConversationManager] Notification callback error:', e)
      }
    }
  }

  /**
   * Send a message to a conversation
   * In demo mode, simulates the server response
   */
  async send(conversationId, content) {
    // For demo: simulate server response via global API
    // Server assigns ID, sequence, timestamp and broadcasts back
    if (window.ReplicateConversation) {
      const api = window.ReplicateConversation
      const messages = api.getMessages?.() || []

      // Get next sequence from existing messages
      const maxSeq = messages.reduce((max, m) => Math.max(max, m.sequence ?? 0), 0)

      const message = {
        id: `msg_${Date.now()}_${Math.random().toString(36).slice(2, 9)}`,
        sequence: maxSeq + 1,
        author: { name: 'You', avatar: null },
        created_at: new Date().toISOString(),
        components: [{ type: 'text', content }],
      }

      // Add message via the global API (simulates server broadcast)
      api.addMessage?.(message)
      return message
    }

    // Real API call (when not in demo mode)
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content

    const response = await fetch(`/conversations/${conversationId}/messages`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken,
      },
      body: JSON.stringify({ content }),
    })

    if (!response.ok) {
      throw new Error(`Failed to send message: ${response.status}`)
    }

    return response.json()
  }
}

// Singleton instance
const manager = new ConversationManager()

// Expose globally for debugging and external access
window.ConversationManager = manager

export default manager