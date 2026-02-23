import React, { useRef, useEffect, useMemo, useImperativeHandle, forwardRef } from 'react'
import Message from './Message'
import TypingIndicator from './TypingIndicator'

/**
 * MessageList - renders all messages with smart auto-scroll
 *
 * Scroll behavior:
 * - Channel switch: Always scroll to bottom
 * - User sends message: Lock to bottom (autoscroll) until they scroll away
 * - Incoming messages: Only autoscroll if in "locked-to-bottom" mode
 * - User scrolls up: Enter "free-scroll" mode, no autoscroll until they send again
 *
 * Thread support:
 * - Messages with `parent_message_id` are thread replies
 * - Thread replies are dynamically grouped under their parent message
 * - Messages are sorted by `sequence` (enforced by DB locks)
 */
export const MessageList = forwardRef(({
  messages,
  isTyping,
  onSelect,
  conversationId, // Used to detect channel switches
}, ref) => {
  const containerRef = useRef(null)

  // Scroll mode: 'locked-to-bottom' | 'free-scroll'
  // - locked-to-bottom: autoscroll on new messages (set when user sends a message)
  // - free-scroll: don't autoscroll (set when user scrolls away from bottom)
  const scrollModeRef = useRef('free-scroll')

  // Track the previous conversation ID to detect channel switches
  const prevConversationIdRef = useRef(conversationId)

  // Track previous message count to detect new messages
  const prevMessageCountRef = useRef(messages.length)

  // Expose scrollToBottom method to parent (called when user sends a message)
  useImperativeHandle(ref, () => ({
    scrollToBottom: () => {
      scrollModeRef.current = 'locked-to-bottom'
      if (containerRef.current) {
        containerRef.current.scrollTop = containerRef.current.scrollHeight
      }
    },
    // Allow parent to check/set scroll mode if needed
    getScrollMode: () => scrollModeRef.current,
    setScrollMode: (mode) => { scrollModeRef.current = mode },
  }), [])

  // Build thread structure from flat message list
  const { rootMessages, threadMap } = useMemo(() => {
    const threadMap = new Map()
    const rootMessages = []

    const sorted = [...messages].sort((a, b) => (a.sequence ?? 0) - (b.sequence ?? 0))

    for (const message of sorted) {
      if (message.parent_message_id) {
        const replies = threadMap.get(message.parent_message_id) || []
        replies.push(message)
        threadMap.set(message.parent_message_id, replies)
      } else {
        rootMessages.push(message)
      }
    }

    return { rootMessages, threadMap }
  }, [messages])

  // Handle channel switch - always scroll to bottom
  useEffect(() => {
    if (conversationId !== prevConversationIdRef.current) {
      prevConversationIdRef.current = conversationId
      prevMessageCountRef.current = messages.length
      // Reset to free-scroll mode but scroll to bottom once
      scrollModeRef.current = 'free-scroll'
      if (containerRef.current) {
        // Use setTimeout to ensure DOM has updated
        setTimeout(() => {
          if (containerRef.current) {
            containerRef.current.scrollTop = containerRef.current.scrollHeight
          }
        }, 0)
      }
    }
  }, [conversationId, messages.length])

  // Handle new messages - only autoscroll if in locked-to-bottom mode
  useEffect(() => {
    const newMessageCount = messages.length
    const hadNewMessages = newMessageCount > prevMessageCountRef.current
    prevMessageCountRef.current = newMessageCount

    if (hadNewMessages && scrollModeRef.current === 'locked-to-bottom' && containerRef.current) {
      containerRef.current.scrollTop = containerRef.current.scrollHeight
    }
  }, [messages])

  // Handle typing indicator - scroll if in locked mode
  useEffect(() => {
    if (isTyping && scrollModeRef.current === 'locked-to-bottom' && containerRef.current) {
      containerRef.current.scrollTop = containerRef.current.scrollHeight
    }
  }, [isTyping])

  // Track scroll position - if user scrolls away from bottom, enter free-scroll mode
  const handleScroll = () => {
    if (!containerRef.current) return
    const { scrollTop, scrollHeight, clientHeight } = containerRef.current
    const distanceFromBottom = scrollHeight - scrollTop - clientHeight

    // If user scrolled more than 100px from bottom, they're reading history
    if (distanceFromBottom > 100) {
      scrollModeRef.current = 'free-scroll'
    } else if (distanceFromBottom < 20) {
      // User scrolled back to bottom, re-enable autoscroll
      scrollModeRef.current = 'locked-to-bottom'
    }
  }

  return (
    <div
      ref={containerRef}
      onScroll={handleScroll}
      className="flex-1 overflow-y-auto overflow-x-hidden"
    >
      {rootMessages.map((message) => (
        <div
          key={message.id}
          className={message.isSystem ? '' : 'py-4 px-4 border-b border-zinc-100 dark:border-zinc-800'}
        >
          <Message
            message={message}
            onSelect={onSelect}
            threadReplies={threadMap.get(message.id)}
          />
        </div>
      ))}
      {isTyping && (
        <div className="py-4 px-4">
          <TypingIndicator author={isTyping} />
        </div>
      )}
    </div>
  )
})

MessageList.displayName = 'MessageList'

export default MessageList