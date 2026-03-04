import React, { useState, useRef, useCallback, forwardRef, useImperativeHandle, useEffect, useMemo } from 'react'
import MessageList from './MessageList'
import MessageInput from './MessageInput'

/**
 * Extract active MCQ from messages - finds the last system message with multiple_choice
 * Returns { mcq, mcqMessageId, filteredMessages }
 */
const extractActiveMCQ = (messages, onSelect) => {
  let mcq = null
  let mcqMessageId = null

  // Find the last system message with an unselected multiple_choice component
  for (let i = messages.length - 1; i >= 0; i--) {
    const msg = messages[i]
    if (msg.isSystem && msg.components) {
      const mcqComponent = msg.components.find(c => c.type === 'multiple_choice')
      if (mcqComponent && !mcqComponent.selected) {
        mcq = mcqComponent
        mcqMessageId = msg.id
        break
      }
    }
  }

  // Filter out multiple_choice components from messages (keep other components like text)
  const filteredMessages = messages.map(msg => {
    if (!msg.components) return msg
    const filteredComponents = msg.components.filter(c => c.type !== 'multiple_choice')
    if (filteredComponents.length === msg.components.length) return msg
    if (filteredComponents.length === 0) return null // Remove message entirely if only had MCQ
    return { ...msg, components: filteredComponents }
  }).filter(Boolean)

  return { mcq, mcqMessageId, filteredMessages }
}

/**
 * MCQ Options rendered below input - clickable hints
 */
const InputHints = ({ mcq, messageId, onSelect, highlightIndex }) => {
  const [hoveredIndex, setHoveredIndex] = React.useState(-1)

  if (!mcq || !mcq.options || mcq.options.length === 0) return null

  const isKeyboardMode = highlightIndex >= 0

  return (
    <div
      className="px-4 py-2"
      style={{
        backgroundColor: '#131316',
        borderTop: '1px solid #1f1f23'
      }}
    >
      {mcq.options.map((option, idx) => {
        const optionId = option.id !== undefined ? option.id : idx
        const displayText = option.thought || option.text
        const messageText = option.message || option.text
        const isHighlighted = highlightIndex === idx || hoveredIndex === idx

        return (
          <div
            key={optionId}
            className="flex items-baseline leading-snug cursor-pointer"
            style={{ paddingTop: '3px', paddingBottom: '3px' }}
            onClick={() => onSelect?.(messageId, optionId, messageText)}
            onMouseEnter={() => setHoveredIndex(idx)}
            onMouseLeave={() => setHoveredIndex(-1)}
          >
            <span
              className="font-mono text-[13px] w-5 flex-shrink-0"
              style={{
                color: isHighlighted ? '#FFFFFF' : '#8DA2FB',
                opacity: isKeyboardMode && !isHighlighted ? 0.4 : 1
              }}
            >
              {idx + 1}.
            </span>
            <span
              className="text-[14px]"
              style={{
                color: isHighlighted ? '#FFFFFF' : '#8DA2FB',
                opacity: isKeyboardMode && !isHighlighted ? 0.4 : 1
              }}
            >
              {displayText}
            </span>
          </div>
        )
      })}
      <div className="text-[12px] mt-1" style={{ color: 'rgba(255, 255, 255, 0.45)' }}>
        Type a number, click an option, or write your own response
      </div>
    </div>
  )
}

/**
 * Conversation - the main chat container
 *
 * This is a presentation component. State management is handled by useConversation hook
 * and passed in as props.
 *
 * Supports two visual variants:
 * - 'macos' (default): macOS-style window chrome with traffic lights
 * - 'irc': Minimal IRC-style header
 */
export const Conversation = forwardRef(({
  messages = [],
  isTyping = false,
  onSend,
  onSelect,
  onRequestHint = null,
  onRequestNew = null,
  placeholder,
  topics = null,
  currentTopic = null,
  onTopicChange = null,
  inputDisabled = false,
  className = '',
  channelName = '#ops-alerts',
  variant = 'macos',
  topic = null,
  userCount = null,
  conversationId = null, // Used for scroll behavior on channel switch
  autoFocusInput = false, // Focus input on mount
}, ref) => {
  const [isFullscreen, setIsFullscreen] = useState(false)
  const [inputValue, setInputValue] = useState('')
  const messageListRef = useRef(null)
  const inputRef = useRef(null)

  // Expose focusInput method to parent via ref
  useImperativeHandle(ref, () => ({
    focusInput: () => {
      inputRef.current?.focus({ preventScroll: true })
    }
  }), [])

  // Auto-focus input on mount if requested
  useEffect(() => {
    if (autoFocusInput) {
      // Small delay to ensure DOM is ready
      requestAnimationFrame(() => {
        inputRef.current?.focus({ preventScroll: true })
      })
    }
  }, [autoFocusInput])

  // Refocus input when new messages come in (without scrolling)
  useEffect(() => {
    if (messages.length > 0) {
      inputRef.current?.focus({ preventScroll: true })
    }
  }, [messages.length])

  // Wrap onSend to also trigger scroll-to-bottom
  // Also intercepts number inputs (1, 2, 3) when MCQ is active
  const handleSend = useCallback((message) => {
    // Trigger scroll to bottom and lock autoscroll mode
    messageListRef.current?.scrollToBottom()
    // Call the original onSend
    onSend?.(message)
    // Clear input value tracking
    setInputValue('')
  }, [onSend])

  // Extract active MCQ from messages (renders below input instead of in message list)
  const { mcq, mcqMessageId, filteredMessages } = useMemo(
    () => extractActiveMCQ(messages, onSelect),
    [messages, onSelect]
  )

  // Compute which option to highlight based on input value
  const highlightIndex = useMemo(() => {
    if (!mcq || !inputValue) return -1
    const trimmed = inputValue.trim()
    const num = parseInt(trimmed, 10)
    if (!isNaN(num) && num >= 1 && num <= mcq.options.length && trimmed === String(num)) {
      return num - 1
    }
    return -1
  }, [mcq, inputValue])

  // Wrap onSelect to also trigger scroll-to-bottom (for MCQ clicks)
  const handleSelect = useCallback((messageId, optionId, optionText) => {
    messageListRef.current?.scrollToBottom()
    onSelect?.(messageId, optionId, optionText)
  }, [onSelect])

  // Handle number selection - intercepts send when input is just a number matching an option
  const handleSendWithMCQ = useCallback((message) => {
    const trimmed = message.trim()
    const num = parseInt(trimmed, 10)

    // If MCQ is active and input is just a number (1, 2, 3, etc.)
    if (mcq && !isNaN(num) && num >= 1 && num <= mcq.options.length && trimmed === String(num)) {
      const option = mcq.options[num - 1]
      const optionId = option.id !== undefined ? option.id : num - 1
      const messageText = option.message || option.text
      // Clear input and trigger selection
      setInputValue('')
      handleSelect(mcqMessageId, optionId, messageText)
      return
    }

    // Otherwise, normal send
    handleSend(message)
  }, [mcq, mcqMessageId, handleSelect, handleSend])

  const baseClasses = 'flex flex-col bg-white dark:bg-zinc-900 overflow-hidden shadow-sm border border-zinc-300 dark:border-zinc-600'
  const fullscreenClasses = isFullscreen
    ? 'fixed inset-0 z-50 rounded-none'
    : `rounded-xl mt-2.5 ${className}`

  // IRC variant - minimal header, supports light/dark
  if (variant === 'irc') {
    return (
      <div className="flex flex-col h-full text-sm overflow-hidden" style={{ backgroundColor: '#18181a' }}>

        {/* Messages area */}
        <MessageList
          ref={messageListRef}
          messages={filteredMessages}
          isTyping={isTyping}
          onSelect={handleSelect}
          conversationId={conversationId}
        />

        {/* Input area */}
        <MessageInput
          ref={inputRef}
          onSend={handleSendWithMCQ}
          onChange={setInputValue}
          placeholder={placeholder}
          disabled={inputDisabled}
          onRequestHint={onRequestHint}
          onRequestNew={onRequestNew}
        />

        {/* MCQ hints below input */}
        <InputHints mcq={mcq} messageId={mcqMessageId} onSelect={handleSelect} highlightIndex={highlightIndex} />
      </div>
    )
  }

  // Default macOS variant
  return (
    <div className={`${baseClasses} ${fullscreenClasses}`}>
      {/* Window chrome (macOS-style dots) */}
      <div className="bg-zinc-100 dark:bg-zinc-800 border-b border-zinc-200 dark:border-zinc-700 px-3 py-2 flex items-center">
        <div className="flex items-center gap-1.5 w-14">
          <a href="https://www.youtube.com/watch?v=dQw4w9WgXcQ" className="w-3 h-3 rounded-full bg-red-400 hover:bg-red-500 cursor-pointer block" />
          <div className="w-3 h-3 rounded-full bg-amber-400 hover:bg-amber-500 cursor-default" />
          <button
            onClick={() => setIsFullscreen(!isFullscreen)}
            className="w-3 h-3 rounded-full bg-green-400 hover:bg-green-500 cursor-pointer"
            title={isFullscreen ? 'Exit fullscreen' : 'Fullscreen'}
          />
        </div>
        <span className="flex-1 text-center text-sm font-medium text-zinc-600 dark:text-zinc-400">{channelName}</span>
        {/* Spacer to balance the traffic lights for true center */}
        <div className="w-14" />
      </div>

      {/* Messages area */}
      <MessageList
        ref={messageListRef}
        messages={messages}
        isTyping={isTyping}
        onSelect={handleSelect}
        conversationId={conversationId}
      />

      {/* Input area */}
      <MessageInput
        ref={inputRef}
        onSend={handleSend}
        placeholder={placeholder}
        topics={topics}
        currentTopic={currentTopic}
        onTopicChange={onTopicChange}
        disabled={inputDisabled}
        showHintIcon={!!onRequestHint}
        onRequestHint={onRequestHint}
      />
    </div>
  )
})

Conversation.displayName = 'Conversation'

export default Conversation