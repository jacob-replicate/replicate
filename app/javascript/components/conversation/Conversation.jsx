import React, { useState } from 'react'
import MessageList from './MessageList'
import MessageInput from './MessageInput'

/**
 * Conversation - the main chat container
 *
 * This is a presentation component. State management is handled by useConversation hook
 * and passed in as props.
 */
export const Conversation = ({
  messages = [],
  isTyping = false,
  onSend,
  onSelect,
  placeholder,
  topics = null,
  currentTopic = null,
  onTopicChange = null,
  inputDisabled = false,
  className = '',
  channelName = '#ops-alerts',
}) => {
  const [isFullscreen, setIsFullscreen] = useState(false)

  const baseClasses = 'flex flex-col bg-white dark:bg-zinc-900 overflow-hidden shadow-sm border border-zinc-300 dark:border-zinc-600'
  const fullscreenClasses = isFullscreen
    ? 'fixed inset-0 z-50 rounded-none'
    : `rounded-xl mt-2.5 ${className}`

  return (
    <div className={`${baseClasses} ${fullscreenClasses}`}>
      {/* Window chrome (optional macOS-style dots) */}
      <div className="bg-zinc-100 dark:bg-zinc-800 border-b border-zinc-200 dark:border-zinc-700 px-3 py-2 flex items-center">
        <div className="flex items-center gap-1.5 w-14">
          <a href="https://www.youtube.com/watch?v=dQw4w9WgXcQ" className="w-3 h-3 rounded-full bg-red-400 hover:bg-red-500 cursor-pointer transition-colors block" />
          <div className="w-3 h-3 rounded-full bg-amber-400 hover:bg-amber-500 cursor-default transition-colors" />
          <button
            onClick={() => setIsFullscreen(!isFullscreen)}
            className="w-3 h-3 rounded-full bg-green-400 hover:bg-green-500 cursor-pointer transition-colors"
            title={isFullscreen ? 'Exit fullscreen' : 'Fullscreen'}
          />
        </div>
        <span className="flex-1 text-center text-sm font-medium text-zinc-600 dark:text-zinc-400">{channelName}</span>
        {/* Spacer to balance the traffic lights for true center */}
        <div className="w-14" />
      </div>

      {/* Messages area */}
      <MessageList
        messages={messages}
        isTyping={isTyping}
        onSelect={onSelect}
      />

      {/* Input area */}
      <MessageInput
        onSend={onSend}
        placeholder={placeholder}
        topics={topics}
        currentTopic={currentTopic}
        onTopicChange={onTopicChange}
        disabled={inputDisabled}
      />
    </div>
  )
}

export default Conversation