import React, { useRef, useEffect } from 'react'
import Message from './Message'
import TypingIndicator from './TypingIndicator'

/**
 * MessageList - renders all messages with auto-scroll
 */
export const MessageList = ({ messages, isTyping, onSelect }) => {
  const containerRef = useRef(null)
  const shouldScrollRef = useRef(true)

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
      {messages.map((message) => (
        <Message key={message.id} message={message} onSelect={onSelect} />
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