import React, { useRef, useEffect, useMemo, useState } from 'react'


// Inline code span
const Code = ({ children }) => (
  <span
    className="font-mono text-[13px] px-1.5 py-0.5 rounded"
    style={{
      color: 'rgba(253, 230, 138, 0.9)',
      backgroundColor: 'rgba(39, 39, 42, 0.8)',
      border: '1px solid rgba(113, 113, 122, 0.7)'
    }}
  >
    {children}
  </span>
)

// Mention component
const Mention = ({ children }) => (
  <span className="text-[#7eb8f5] font-medium hover:underline cursor-pointer">
    {children}
  </span>
)

/**
 * Parse text content and convert @mentions and `inline code` to components
 * Returns an array of strings and React elements
 */
const parseTextContent = (text) => {
  if (!text) return null

  // Pattern matches @mentions and `inline code`
  // @mention: @ followed by word characters (letters, numbers, underscores)
  // inline code: text between backticks
  const pattern = /(@\w+)|(`[^`]+`)/g

  const parts = []
  let lastIndex = 0
  let match

  while ((match = pattern.exec(text)) !== null) {
    // Add text before the match
    if (match.index > lastIndex) {
      parts.push(text.slice(lastIndex, match.index))
    }

    if (match[1]) {
      // @mention
      parts.push(<Mention key={match.index}>{match[1]}</Mention>)
    } else if (match[2]) {
      // `inline code` - remove the backticks
      const code = match[2].slice(1, -1)
      parts.push(<Code key={match.index}>{code}</Code>)
    }

    lastIndex = pattern.lastIndex
  }

  // Add remaining text after last match
  if (lastIndex < text.length) {
    parts.push(text.slice(lastIndex))
  }

  return parts.length > 0 ? parts : text
}

// Emoji reaction pill - clickable with hover effects
// isSelected shows a highlighted state when user has reacted
const EmojiReaction = ({ emoji, count, onClick, isSelected }) => {
  const [isHovered, setIsHovered] = React.useState(false)

  const baseStyle = isSelected
    ? {
        backgroundColor: isHovered ? 'rgba(99, 102, 241, 0.3)' : 'rgba(99, 102, 241, 0.2)',
        border: '1px solid rgba(99, 102, 241, 0.5)',
        color: '#a5b4fc'
      }
    : {
        backgroundColor: isHovered ? '#3f3f46' : '#27272a',
        border: '1px solid #3f3f46',
        color: '#a1a1aa'
      }

  return (
    <button
      onClick={onClick}
      onMouseEnter={() => setIsHovered(true)}
      onMouseLeave={() => setIsHovered(false)}
      className="inline-flex items-center gap-1 px-1.5 py-0.5 rounded-full text-xs active:scale-95 transition-all cursor-pointer"
      style={baseStyle}
    >
      <span style={{ filter: 'grayscale(30%)', opacity: 0.9 }}>{emoji}</span>
      <span>{count}</span>
    </button>
  )
}


// Diff component
const Diff = ({ filename, lines }) => {
  // Calculate additions and deletions dynamically from lines
  const additions = lines.filter(line => line.type === 'add').length
  const deletions = lines.filter(line => line.type === 'remove').length

  return (
    <div className="rounded overflow-hidden text-[13px] font-mono" style={{ border: '1px solid #27272a' }}>
      {filename && (
        <div className="px-2 py-1 flex items-center justify-between" style={{ backgroundColor: '#1f1f23', color: '#a1a1aa', borderBottom: '1px solid #27272a' }}>
          <span>{filename}</span>
          {(additions > 0 || deletions > 0) && (
            <div className="flex items-center gap-2">
              {additions > 0 && <span style={{ color: '#4ade80' }}>+{additions}</span>}
              {deletions > 0 && <span style={{ color: '#f87171' }}>-{deletions}</span>}
            </div>
          )}
        </div>
      )}
      {lines.map((line, i) => {
        if (line.type === 'remove') {
          return (
            <div key={i} className="px-2 py-0.5" style={{ backgroundColor: 'rgba(127, 29, 29, 0.3)', color: '#fca5a5' }}>
              <span className="select-none mr-2" style={{ color: '#f87171' }}>-</span>
              {line.text}
            </div>
          )
        }
        if (line.type === 'add') {
          return (
            <div key={i} className="px-2 py-0.5" style={{ backgroundColor: 'rgba(20, 83, 45, 0.4)', color: '#86efac' }}>
              <span className="select-none mr-2" style={{ color: '#4ade80' }}>+</span>
              {line.text}
            </div>
          )
        }
        return (
          <div key={i} className="px-2 py-0.5" style={{ color: '#a1a1aa' }}>
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
    <pre className="text-[13px] leading-[1.5] overflow-x-auto">
      <code ref={codeRef} className={`language-${language || 'plaintext'} block`}>
        {code}
      </code>
    </pre>
  )
}

// OncallAlert component (PagerDuty-style)
const OncallAlert = ({ severity = 'SEV-1', service, alert, error, affected, commit }) => {
  const severityColors = {
    'SEV-1': { bg: 'bg-red-500/20', text: 'text-red-400', border: 'border-red-500/30' },
    'SEV-2': { bg: 'bg-orange-500/20', text: 'text-orange-400', border: 'border-orange-500/30' },
  }
  const colors = severityColors[severity] || severityColors['SEV-1']

  return (
    <div className="rounded-lg bg-zinc-800 border border-zinc-700 p-4 mt-1">
      <div className="flex items-start justify-between gap-4">
        <div className="flex items-start gap-3">
          <div className="w-2 h-2 rounded-full bg-red-500 animate-pulse flex-shrink-0 mt-1.5" />
          <div>
            <div className="flex items-center gap-2 mb-1">
              <span className="text-white font-medium">{service}</span>
              <span className={`px-1.5 py-0.5 rounded text-xs font-bold ${colors.bg} ${colors.text} ${colors.border} border`}>{severity}</span>
            </div>
            <div className="text-zinc-400 text-sm mb-1">{alert}</div>
            <div className="flex items-center gap-3 text-xs">
              {affected && <span className="text-zinc-400">{affected}</span>}
              {commit && <><span className="text-zinc-500">•</span><span className="text-zinc-400 font-mono">{commit}</span></>}
            </div>
          </div>
        </div>
        {error && (
          <span className="font-mono text-red-400 bg-red-500/10 px-2 py-1 rounded text-xs flex-shrink-0">{error}</span>
        )}
      </div>
    </div>
  )
}

// Countdown component for timed thinking exercises
const Countdown = ({ duration = 30, label = 'Think through your approach', onComplete }) => {
  const [timeLeft, setTimeLeft] = useState(duration)
  const [isComplete, setIsComplete] = useState(false)

  useEffect(() => {
    if (timeLeft <= 0) {
      setIsComplete(true)
      onComplete?.()
      return
    }

    const timer = setTimeout(() => {
      setTimeLeft(t => t - 1)
    }, 1000)

    return () => clearTimeout(timer)
  }, [timeLeft, onComplete])

  const progress = ((duration - timeLeft) / duration) * 100
  const minutes = Math.floor(timeLeft / 60)
  const seconds = timeLeft % 60
  const timeDisplay = minutes > 0 ? `${minutes}:${seconds.toString().padStart(2, '0')}` : `${seconds}s`

  if (isComplete) {
    return (
      <div className="rounded-lg bg-emerald-50 dark:bg-emerald-900/20 border border-emerald-200 dark:border-emerald-800 p-4 mt-2">
        <div className="flex items-center gap-3">
          <div className="w-8 h-8 rounded-full bg-emerald-500 flex items-center justify-center">
            <svg className="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
            </svg>
          </div>
          <div>
            <div className="font-medium text-emerald-900 dark:text-emerald-100">Time's up!</div>
            <div className="text-sm text-emerald-700 dark:text-emerald-300">Now let's see how another engineer approached this...</div>
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="rounded-lg bg-amber-50 dark:bg-amber-900/20 border border-amber-200 dark:border-amber-800 p-4 mt-2">
      <div className="flex items-center justify-between mb-3">
        <div className="flex items-center gap-3">
          <div className="w-8 h-8 rounded-full bg-amber-500 flex items-center justify-center">
            <svg className="w-5 h-5 text-white animate-pulse" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
          </div>
          <div>
            <div className="font-medium text-amber-900 dark:text-amber-100">{label}</div>
            <div className="text-sm text-amber-700 dark:text-amber-300">Visualize your solution before seeing the draft</div>
          </div>
        </div>
        <div className="text-2xl font-mono font-bold text-amber-600 dark:text-amber-400 tabular-nums">
          {timeDisplay}
        </div>
      </div>
      <div className="h-2 bg-amber-200 dark:bg-amber-800 rounded-full overflow-hidden">
        <div
          className="h-full bg-amber-500 transition-all duration-1000 ease-linear"
          style={{ width: `${progress}%` }}
        />
      </div>
    </div>
  )
}

// Multiple choice component - terminal-style numbered options
const MultipleChoice = ({ question, options, onSelect, selectedId, disabled = false }) => {
  const hasSelection = selectedId !== undefined && selectedId !== null

  return (
    <div className="pt-0.5 pb-2 pl-14 pr-4">
      {options && options.length > 0 && (
        <div>
          {options.map((option, idx) => {
            const optionId = option.id !== undefined ? option.id : idx
            const isSelected = selectedId === optionId
            const isDisabled = disabled || (hasSelection && !isSelected)
            const canInteract = !disabled && !hasSelection
            // Display thought (internal thinking), send message (Slack message)
            const displayText = option.thought || option.text
            const messageText = option.message || option.text

            return (
              <div
                key={optionId}
                className={`flex items-baseline leading-snug ${
                  isDisabled
                    ? 'opacity-30'
                    : canInteract ? 'cursor-pointer' : ''
                }`}
                style={{ paddingTop: '2px', paddingBottom: '2px' }}
                onClick={() => canInteract && onSelect?.(optionId, messageText)}
              >
                <span
                  className="font-mono text-[13px] w-5 flex-shrink-0"
                  style={{ color: canInteract ? 'rgba(140, 160, 220, 0.7)' : '#3f3f46' }}
                >
                  {idx + 1}.
                </span>
                <span
                  className={`text-[14px] ${canInteract ? 'hover:underline underline-offset-2' : ''}`}
                  style={{
                    color: canInteract ? '#93a8f4' : '#3f3f46',
                    textDecorationColor: 'rgba(147, 168, 244, 0.5)'
                  }}
                >
                  {displayText}
                </span>
              </div>
            )
          })}
        </div>
      )}
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
export const Message = ({ message, onSelect }) => {
  const { author, components, reactions, created_at, updated_at, isSystem } = message
  // Legacy support for old structure
  const { content, type, metadata, timestamp, edited } = message
  const { name, avatar, status } = author || {}

  // Track which reactions the user has selected (by emoji)
  const [selectedReactions, setSelectedReactions] = useState(new Set())
  // Track count adjustments for user clicks (emoji -> adjustment amount)
  const [reactionAdjustments, setReactionAdjustments] = useState({})

  // Handle reaction click - toggle selected and adjust count
  const handleReactionClick = (emoji) => {
    setSelectedReactions(prev => {
      const newSet = new Set(prev)
      if (newSet.has(emoji)) {
        newSet.delete(emoji)
      } else {
        newSet.add(emoji)
      }
      return newSet
    })
    setReactionAdjustments(prev => {
      const currentAdj = prev[emoji] || 0
      const isCurrentlySelected = selectedReactions.has(emoji)
      // If currently selected, we're unselecting so decrement
      // If not selected, we're selecting so increment
      return {
        ...prev,
        [emoji]: isCurrentlySelected ? currentAdj - 1 : currentAdj + 1
      }
    })
  }

  // Derive edited status from updated_at (or use legacy edited field)
  const isEdited = edited || (updated_at && updated_at !== created_at)


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

      case 'countdown':
        return (
          <Countdown
            key={index}
            duration={component.duration}
            label={component.label}
            onComplete={component.onComplete}
          />
        )

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

      case 'oncall_alert':
        return (
          <OncallAlert
            key={index}
            severity={component.severity}
            service={component.service}
            alert={component.alert}
            error={component.error}
            affected={component.affected}
            commit={component.commit}
          />
        )


      case 'text':
      default:
        return (
          <div key={index} className="text-zinc-200 text-[15px] whitespace-pre-wrap">
            {parseTextContent(component.content)}
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
          <div className="text-zinc-200 text-[15px] whitespace-pre-wrap">
            {content}
          </div>
        )
    }
  }

  // Special rendering for system messages - no avatar/name, flush content
  if (isSystem) {
    return renderContent()
  }


  const messageContent = (
    <div className="flex items-start gap-3">
      {avatar ? (
        <img src={avatar} alt="" className="w-10 h-10 rounded-full flex-shrink-0 ring-1 ring-zinc-700/60" style={{ filter: 'brightness(0.9) saturate(0.9)' }} />
      ) : (
        <div className="w-10 h-10 rounded-full flex-shrink-0 bg-zinc-200 dark:bg-zinc-700 flex items-center justify-center text-zinc-500 dark:text-zinc-400 text-sm font-medium">
          {name?.[0]?.toUpperCase() || '?'}
        </div>
      )}
      <div className="flex-1 min-w-0">
        {(name || timeStr || isEdited) && (
          <div className="flex items-baseline gap-2 flex-wrap">
            {name && (
              <span className="font-semibold text-zinc-100 text-[15px] tracking-[-0.01em]">
                {name}
              </span>
            )}
            {status && (
              <span className="text-[12px] text-zinc-500 dark:text-zinc-400">{status.emoji} {status.text}</span>
            )}
            {timeStr && (
              <span className="text-zinc-500 text-[12px]">{timeStr}</span>
            )}
            {isEdited && (
              <span className="text-zinc-500 text-[11px]">(edited)</span>
            )}
          </div>
        )}
        <div className="mt-0.5">
          {renderContent()}
        </div>
        {(reactions || metadata?.reactions) && (
          <div className="mt-2 flex gap-1">
            {(reactions || metadata?.reactions).map((r, i) => (
              <EmojiReaction
                key={i}
                emoji={r.emoji}
                count={r.count + (reactionAdjustments[r.emoji] || 0)}
                onClick={() => handleReactionClick(r.emoji)}
                isSelected={selectedReactions.has(r.emoji)}
              />
            ))}
          </div>
        )}
      </div>
    </div>
  )

  return messageContent
}

// Export helper components for direct use
export { Code, Mention, EmojiReaction, Diff, CodeBlock, MultipleChoice, AlertBlock }
export default Message