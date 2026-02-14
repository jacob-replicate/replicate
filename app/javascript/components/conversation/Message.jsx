import React, { useRef, useEffect, useMemo } from 'react'

// Inline code span
const Code = ({ children }) => (
  <span className="font-mono bg-zinc-100 dark:bg-zinc-800 px-1 rounded text-[13px]">
    {children}
  </span>
)

// Mention component
const Mention = ({ children }) => (
  <span className="text-[#1264a3] dark:text-blue-400 bg-[#e8f5fa] dark:bg-blue-900/30 rounded px-0.5 font-medium">
    {children}
  </span>
)

// Emoji reaction pill
const EmojiReaction = ({ emoji, count }) => (
  <span className="inline-flex items-center gap-1 px-1.5 py-0.5 rounded-full bg-zinc-100 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-xs">
    <span>{emoji}</span>
    <span className="text-zinc-600 dark:text-zinc-400">{count}</span>
  </span>
)

// Thread replies component
const ThreadReplies = ({ replies }) => {
  const [expanded, setExpanded] = React.useState(false)
  // Track how many replies existed when we expanded - these show instantly
  const [repliesAtExpand, setRepliesAtExpand] = React.useState(0)
  // Track how many NEW replies (after expand) are visible (for typing animation)
  const [visibleNewReplies, setVisibleNewReplies] = React.useState(0)

  // When expanding, snapshot current reply count - these show instantly
  useEffect(() => {
    if (expanded) {
      setRepliesAtExpand(replies.length)
      setVisibleNewReplies(0)
    }
  }, [expanded])

  // Animate in only NEW replies that arrive after expansion
  const newRepliesCount = replies.length - repliesAtExpand
  useEffect(() => {
    if (!expanded || visibleNewReplies >= newRepliesCount) return
    const timeout = setTimeout(() => {
      setVisibleNewReplies(v => v + 1)
    }, 800 + Math.random() * 600)
    return () => clearTimeout(timeout)
  }, [expanded, visibleNewReplies, newRepliesCount])

  // Total visible = all replies at expand time + animated new replies
  const totalVisible = expanded ? repliesAtExpand + visibleNewReplies : 0

  const lastReply = replies[replies.length - 1]

  return (
    <div className="mt-2">
      <button
        onClick={() => setExpanded(!expanded)}
        className="flex items-center gap-2 text-[13px] text-[#1264a3] dark:text-blue-400 hover:underline"
      >
        <svg
          className={`w-4 h-4 transition-transform ${expanded ? 'rotate-90' : ''}`}
          viewBox="0 0 16 16"
          fill="currentColor"
        >
          <path
            d="M6 12l4-4-4-4"
            stroke="currentColor"
            strokeWidth="1.5"
            fill="none"
            strokeLinecap="round"
            strokeLinejoin="round"
          />
        </svg>
        <span className="font-medium">
          {replies.length} {replies.length === 1 ? 'reply' : 'replies'}
        </span>
        {!expanded && lastReply && (
          <span className="text-zinc-500 dark:text-zinc-400 truncate max-w-[200px]">
            {lastReply.name}:{lastReply.avatar && <img src={lastReply.avatar} alt="" className="w-4 h-4 rounded-full inline ml-1 mr-1" />} {lastReply.text?.slice(0, 25)}{lastReply.text?.length > 25 ? '...' : ''}
          </span>
        )}
      </button>

      {expanded && (
        <div className="mt-2 ml-1 pl-3 border-l-2 border-zinc-200 dark:border-zinc-700 space-y-2">
          {replies.slice(0, totalVisible).map((reply, i) => (
            <div key={i} className="flex items-start gap-2">
              {reply.avatar && (
                <img src={reply.avatar} alt="" className="w-6 h-6 rounded-full flex-shrink-0" />
              )}
              <div>
                <span className="font-semibold text-[13px] text-[#1d1c1d] dark:text-zinc-100">
                  {reply.name}
                </span>
                {reply.time && (
                  <span className="text-zinc-500 dark:text-zinc-400 text-[11px] ml-1.5">
                    {reply.time}
                  </span>
                )}
                <div className="text-[13px] text-[#1d1c1d] dark:text-zinc-300">
                  {reply.text}
                </div>
              </div>
            </div>
          ))}
          {totalVisible < replies.length && (
            <div className="flex items-center gap-2 text-zinc-400 text-[12px]">
              <div className="flex gap-0.5">
                <div className="w-1.5 h-1.5 bg-zinc-400 dark:bg-zinc-500 rounded-full animate-bounce" style={{ animationDelay: '0ms', animationDuration: '600ms' }} />
                <div className="w-1.5 h-1.5 bg-zinc-400 dark:bg-zinc-500 rounded-full animate-bounce" style={{ animationDelay: '150ms', animationDuration: '600ms' }} />
                <div className="w-1.5 h-1.5 bg-zinc-400 dark:bg-zinc-500 rounded-full animate-bounce" style={{ animationDelay: '300ms', animationDuration: '600ms' }} />
              </div>
            </div>
          )}
        </div>
      )}
    </div>
  )
}

// Diff component
const Diff = ({ filename, lines }) => {
  // Calculate additions and deletions dynamically from lines
  const additions = lines.filter(line => line.type === 'add').length
  const deletions = lines.filter(line => line.type === 'remove').length

  return (
    <div className="rounded border border-zinc-200 dark:border-zinc-700 overflow-hidden text-[13px] font-mono">
      {filename && (
        <div className="bg-zinc-100 dark:bg-zinc-800 px-2 py-1 text-zinc-500 dark:text-zinc-400 border-b border-zinc-200 dark:border-zinc-700 flex items-center justify-between">
          <span>{filename}</span>
          {(additions > 0 || deletions > 0) && (
            <div className="flex items-center gap-2">
              {additions > 0 && <span className="text-green-600 dark:text-green-400">+{additions}</span>}
              {deletions > 0 && <span className="text-red-500 dark:text-red-400">-{deletions}</span>}
            </div>
          )}
        </div>
      )}
      {lines.map((line, i) => {
        if (line.type === 'remove') {
          return (
            <div key={i} className="bg-red-50 dark:bg-red-950/30 px-2 py-0.5 text-red-700 dark:text-red-300">
              <span className="text-red-400 dark:text-red-500 select-none mr-2">-</span>
              {line.text}
            </div>
          )
        }
        if (line.type === 'add') {
          return (
            <div key={i} className="bg-green-50 dark:bg-green-950/30 px-2 py-0.5 text-green-700 dark:text-green-300">
              <span className="text-green-500 select-none mr-2">+</span>
              {line.text}
            </div>
          )
        }
        return (
          <div key={i} className="px-2 py-0.5 text-zinc-600 dark:text-zinc-400">
            <span className="select-none mr-2">&nbsp;</span>
            {line.text}
          </div>
        )
      })}
    </div>
  )
}

// Code block with syntax highlighting
const CodeBlock = ({ code, language }) => {
  const codeRef = useRef(null)

  useEffect(() => {
    if (codeRef.current && window.hljs) {
      window.hljs.highlightElement(codeRef.current)
    }
  }, [code])

  return (
    <pre className="rounded-md text-[13px] leading-[1.5] overflow-x-auto !p-0 border border-zinc-200 dark:border-zinc-600">
      <code ref={codeRef} className={`language-${language || 'plaintext'} !p-4 block`}>
        {code}
      </code>
    </pre>
  )
}

// Multiple choice component
const MultipleChoice = ({ question, options, onSelect, selectedId, disabled = false }) => {
  const hasSelection = selectedId !== undefined && selectedId !== null

  return (
    <div>
      {question && (
        <div className="text-[#1d1c1d] dark:text-zinc-200 text-[15px] mb-3">{question}</div>
      )}
      <div className="flex flex-col bg-gray-50 dark:bg-zinc-800/60 border border-gray-200 dark:border-zinc-600 shadow-sm rounded-lg overflow-hidden">
        {options.map((option, idx) => {
          const optionId = option.id !== undefined ? option.id : idx
          const isSelected = selectedId === optionId
          const isDisabled = disabled || (hasSelection && !isSelected)
          const canInteract = !disabled && !hasSelection

          return (
            <label
              key={optionId}
              className={`text-[15px] flex items-center p-[12px] transition-colors ${
                idx < options.length - 1 ? 'border-b border-gray-200 dark:border-zinc-600' : ''
              } ${
                isSelected
                  ? 'bg-indigo-100 dark:bg-indigo-900/50'
                  : isDisabled
                    ? 'opacity-50 cursor-default'
                    : 'cursor-pointer hover:bg-indigo-50 dark:hover:bg-indigo-900/40'
              }`}
            >
              <input
                type="radio"
                name={`mc_${question?.slice(0, 20) || 'choice'}_${options.length}`}
                checked={isSelected}
                disabled={isDisabled}
                onChange={() => canInteract && onSelect?.(optionId, option.text)}
                className="h-4 w-4 text-indigo-600 border-gray-400 dark:border-zinc-500 focus:ring-indigo-500 dark:bg-zinc-700 disabled:cursor-default"
              />
              <span className="ml-3 text-zinc-800 dark:text-zinc-200">{option.text}</span>
            </label>
          )
        })}
      </div>
    </div>
  )
}

// Alert block (PagerDuty-style)
const AlertBlock = ({ severity, title, description, metadata }) => {
  const severityColors = {
    'SEV-1': 'border-red-500 text-red-600 dark:text-red-400',
    'SEV-2': 'border-orange-500 text-orange-600 dark:text-orange-400',
    'SEV-3': 'border-yellow-500 text-yellow-600 dark:text-yellow-400',
    default: 'border-zinc-400 text-zinc-600 dark:text-zinc-400',
  }
  const colorClass = severityColors[severity] || severityColors.default

  return (
    <div className={`border-l-4 ${colorClass.split(' ')[0]} bg-[#f8f8f8] dark:bg-zinc-800 rounded-r px-3 py-2`}>
      <div className={`font-mono text-[13px] ${colorClass.split(' ').slice(1).join(' ')} mb-1`}>
        {severity && `[${severity}] `}{title}
      </div>
      {description && (
        <div className="text-[#1d1c1d] dark:text-zinc-100 text-sm font-medium">{description}</div>
      )}
      {metadata && (
        <div className="text-[#616061] dark:text-zinc-400 text-xs mt-1">{metadata}</div>
      )}
    </div>
  )
}

/**
 * Main Message component - renders different message types
 */
export const Message = ({ message, onSelect, threadReplies }) => {
  const { author, components, reactions, thread, created_at, updated_at } = message
  // Legacy support for old structure
  const { content, type, metadata, timestamp, edited } = message
  const { name, avatar } = author || {}

  // Derive edited status from updated_at (or use legacy edited field)
  const isEdited = edited || (updated_at && updated_at !== created_at)

  // Convert threadReplies (full messages) to the format ThreadReplies component expects
  // This allows both the old `thread` array format and the new `parent_message_id` approach
  const computedThread = useMemo(() => {
    if (thread || metadata?.thread) {
      return thread || metadata?.thread // Legacy format
    }
    if (threadReplies && threadReplies.length > 0) {
      // Convert full messages to thread reply format
      return threadReplies.map(reply => ({
        avatar: reply.author?.avatar,
        name: reply.author?.name,
        time: reply.created_at
          ? new Date(reply.created_at).toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit' })
          : null,
        text: reply.components?.[0]?.content || reply.content || '',
      }))
    }
    return null
  }, [thread, metadata?.thread, threadReplies])

  // Format timestamp - prefer created_at, fall back to legacy timestamp
  const timeStr = (created_at || timestamp)
    ? new Date(created_at || timestamp).toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit' })
    : null

  // Render a single component
  const renderComponent = (component, index) => {
    switch (component.type) {
      case 'alert':
        return (
          <AlertBlock
            key={index}
            severity={component.severity}
            title={component.title}
            description={component.description}
            metadata={component.meta}
          />
        )

      case 'code':
        return <CodeBlock key={index} code={component.content} language={component.language} />

      case 'diff':
        return (
          <Diff
            key={index}
            filename={component.filename}
            lines={component.lines || []}
            additions={component.additions}
            deletions={component.deletions}
          />
        )

      case 'multiple_choice':
        return (
          <MultipleChoice
            key={index}
            question={component.question}
            options={component.options || []}
            onSelect={(id, optionText) => onSelect?.(message.id, id, optionText)}
            selectedId={component.selected}
            disabled={component.disabled}
          />
        )

      case 'text':
      default:
        return (
          <div key={index} className="text-[#1d1c1d] dark:text-zinc-200 text-[15px] whitespace-pre-wrap">
            {component.content}
          </div>
        )
    }
  }

  // Render content - supports both new components array and legacy single type
  const renderContent = () => {
    // New structure with components array
    if (components && components.length > 0) {
      return (
        <div className="space-y-2">
          {components.map((component, index) => renderComponent(component, index))}
        </div>
      )
    }

    // Legacy structure with single type/content
    switch (type) {
      case 'alert':
        return (
          <AlertBlock
            severity={metadata?.severity}
            title={metadata?.title || content}
            description={metadata?.description}
            metadata={metadata?.meta}
          />
        )

      case 'code':
        return <CodeBlock code={content} language={metadata?.language} />

      case 'diff':
        return (
          <Diff
            filename={metadata?.filename}
            lines={metadata?.lines || []}
            additions={metadata?.additions}
            deletions={metadata?.deletions}
          />
        )

      case 'multiple_choice':
        return (
          <MultipleChoice
            question={content}
            options={metadata?.options || []}
            onSelect={(id, optionText) => onSelect?.(message.id, id, optionText)}
            selectedId={metadata?.selectedId}
            disabled={metadata?.disabled}
          />
        )

      case 'text':
      default:
        if (!content) return null
        return (
          <div className="text-[#1d1c1d] dark:text-zinc-200 text-[15px] whitespace-pre-wrap">
            {content}
          </div>
        )
    }
  }

  return (
    <div className="flex items-start gap-3">
      {avatar ? (
        <img src={avatar} alt="" className="w-10 h-10 rounded-full flex-shrink-0" />
      ) : (
        <div className="w-10 h-10 rounded-full flex-shrink-0 bg-zinc-200 dark:bg-zinc-700 flex items-center justify-center text-zinc-500 dark:text-zinc-400 text-sm font-medium">
          {name?.[0]?.toUpperCase() || '?'}
        </div>
      )}
      <div className="flex-1 min-w-0">
        <div className="flex items-baseline gap-2 flex-wrap">
          <span className="font-semibold text-[#1d1c1d] dark:text-zinc-100 text-[15px] tracking-[-0.01em]">
            {name || 'Unknown'}
          </span>
          {timeStr && (
            <span className="text-[#616061] dark:text-zinc-500 text-[12px]">{timeStr}</span>
          )}
          {isEdited && (
            <span className="text-[#616061] dark:text-zinc-500 text-[11px]">(edited)</span>
          )}
        </div>
        <div className="mt-0.5">
          {renderContent()}
        </div>
        {(reactions || metadata?.reactions) && (
          <div className="mt-2 flex gap-1">
            {(reactions || metadata?.reactions).map((r, i) => (
              <EmojiReaction key={i} emoji={r.emoji} count={r.count} />
            ))}
          </div>
        )}
        {computedThread && computedThread.length > 0 && (
          <ThreadReplies replies={computedThread} />
        )}
      </div>
    </div>
  )
}

// Export helper components for direct use
export { Code, Mention, EmojiReaction, ThreadReplies, Diff, CodeBlock, MultipleChoice, AlertBlock }
export default Message