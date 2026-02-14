import React from 'react'
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
}) => {
  return (
    <div className={`flex flex-col bg-white dark:bg-zinc-900 rounded-xl overflow-hidden shadow-sm border border-zinc-200/60 dark:border-zinc-700 ${className}`}>
      {/* Window chrome (optional macOS-style dots) */}
      <div className="bg-zinc-100 dark:bg-zinc-800 border-b border-zinc-200 dark:border-zinc-700 px-3 py-2 flex items-center">
        <div className="flex items-center gap-1.5">
          <div className="w-3 h-3 rounded-full bg-red-400 hover:bg-red-500 cursor-default transition-colors" />
          <div className="w-3 h-3 rounded-full bg-amber-400 hover:bg-amber-500 cursor-default transition-colors" />
          <div className="w-3 h-3 rounded-full bg-green-400 hover:bg-green-500 cursor-default transition-colors" />
        </div>
        <span className="flex-1 text-center text-sm font-medium text-zinc-600 dark:text-zinc-400">#ops-alerts</span>
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