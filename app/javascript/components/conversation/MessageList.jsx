import React, { useRef, useEffect, useMemo } from 'react'
import Message from './Message'
import TypingIndicator from './TypingIndicator'

/**
 * MessageList - renders all messages with auto-scroll
 *
 * Thread support:
 * - Messages with `parent_message_id` are thread replies
 * - Thread replies are dynamically grouped under their parent message
 * - Messages are sorted by `sequence` (enforced by DB locks)
 */
export const MessageList = ({ messages, isTyping, onSelect }) => {
  const containerRef = useRef(null)
  const shouldScrollRef = useRef(true)

  // Build thread structure from flat message list
  // Messages with parent_message_id are grouped as replies to their parent
  const { rootMessages, threadMap } = useMemo(() => {
    const threadMap = new Map() // parent_message_id -> array of reply messages
    const rootMessages = []

    // Sort by sequence to ensure correct order
    const sorted = [...messages].sort((a, b) => {
      const seqA = a.components?.[0]?.sequence ?? 0
      const seqB = b.components?.[0]?.sequence ?? 0
      return seqA - seqB
    })

    for (const message of sorted) {
      if (message.parent_message_id) {
        // This is a thread reply
        const replies = threadMap.get(message.parent_message_id) || []
        replies.push(message)
        threadMap.set(message.parent_message_id, replies)
      } else {
        // This is a root message
        rootMessages.push(message)
      }
    }

    return { rootMessages, threadMap }
  }, [messages])

  // Auto-scroll to bottom when new messages arrive (if already at bottom)
  useEffect(() => {
    if (containerRef.current && shouldScrollRef.current) {
      containerRef.current.scrollTop = containerRef.current.scrollHeight
    }
  }, [messages, isTyping])

  // Track scroll position to determine if we should auto-scroll
  const handleScroll = () => {
    if (!containerRef.current) return
    const { scrollTop, scrollHeight, clientHeight } = containerRef.current
    shouldScrollRef.current = scrollHeight - scrollTop - clientHeight < 100
  }

  return (
    <div
      ref={containerRef}
      onScroll={handleScroll}
      className="flex-1 overflow-y-auto divide-y divide-zinc-200 dark:divide-zinc-700 [&>*]:py-4 [&>*]:px-4"
    >
      {rootMessages.map((message) => (
        <Message
          key={message.id}
          message={message}
          onSelect={onSelect}
          threadReplies={threadMap.get(message.id)}
        />
      ))}
      {isTyping && (
        <div className="py-4 px-4">
          <TypingIndicator author={isTyping} />
        </div>
      )}
    </div>
  )
}

export default MessageList