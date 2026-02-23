import React, { useRef, useEffect, useMemo, useState } from 'react'


// Inline code span
const Code = ({ children }) => (
  <span className="font-mono bg-zinc-100 dark:bg-zinc-800 px-1 rounded text-[13px] text-pink-600 dark:text-pink-400">
    {children}
  </span>
)

// Mention component
const Mention = ({ children }) => (
  <span className="text-[#1264a3] dark:text-blue-400 bg-[#e8f5fa] dark:bg-blue-900/30 rounded px-0.5 font-medium">
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
const EmojiReaction = ({ emoji, count, onClick, isSelected }) => (
  <button
    onClick={onClick}
    className={`inline-flex items-center gap-1 px-1.5 py-0.5 rounded-full text-xs active:scale-95 transition-all cursor-pointer ${
      isSelected
        ? 'bg-indigo-100 dark:bg-indigo-900/50 border border-indigo-300 dark:border-indigo-700 hover:bg-indigo-200 dark:hover:bg-indigo-800/50'
        : 'bg-zinc-100 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 hover:bg-zinc-200 dark:hover:bg-zinc-700 hover:border-zinc-300 dark:hover:border-zinc-600'
    }`}
  >
    <span>{emoji}</span>
    <span className={isSelected ? 'text-indigo-600 dark:text-indigo-400' : 'text-zinc-600 dark:text-zinc-400'}>{count}</span>
  </button>
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

// Monitor component (Datadog-style metric chart)
// Default theme values
const DEFAULT_MONITOR_THEME = {
  bg: '#f9f8fc',
  border: 'rgba(99, 79, 135, 0.25)',
  titleColor: '#1a1523',
  metaColor: '#5c5470',
  dimColor: '#7a7189',
  valueColor: '#c4314b',
  lineColor: '#634f87',
  gridColor: '#eeeaf4',
  gridDashColor: '#b3a9c4',
  // 3 zone colors: neutral, warning, alert
  neutral: 'rgba(99, 79, 135, 0.04)',
  warning: 'rgba(253, 224, 71, 0.12)',
  alert: 'rgba(244, 63, 94, 0.20)',
  separatorColor: 'rgba(99, 79, 135, 0.15)',
  areaFillTop: 0.10,
  areaFillBottom: 0.10,
  areaColor: '#4f46e5',
}

// Default data points (rising to critical)
const DEFAULT_DATA_POINTS = [
  12, 14, 13, 15, 18, 16, 22, 25, 24, 28,
  35, 32, 38, 45, 42, 52, 58, 65, 72, 68,
  75, 82, 78, 85, 88, 92, 89, 94, 96, 98
]

// Default zone breaks [neutral, warning, alert] - 3 zones
const DEFAULT_ZONE_BREAKS = [0, 0.6, 0.85, 1.05]

// Data-driven monitor card - all config comes from props
const Monitor = ({ title, metric, value, theme = {}, dataPoints, zoneBreaks, region = 'us-east-1', timeRange = 'Last 15m' }) => {
  // Merge provided theme with defaults
  const t = { ...DEFAULT_MONITOR_THEME, ...theme }

  // Use provided data points or defaults
  const points = React.useMemo(() => {
    const basePoints = dataPoints || DEFAULT_DATA_POINTS
    return basePoints.map(p => Math.max(0, Math.min(100, p + (Math.random() - 0.5) * 2)))
  }, [dataPoints])

  // Use provided zone breaks or defaults
  const zones = zoneBreaks || DEFAULT_ZONE_BREAKS

  const chartHeight = 36
  const toY = (pct) => chartHeight - (pct / 100) * chartHeight
  const pathPoints = points.map((val, i) => `${(i / (points.length - 1)) * 200},${toY(val)}`).join(' L')
  const linePath = `M${pathPoints}`
  const areaPath = `${linePath} L200,${chartHeight} L0,${chartHeight} Z`
  const gradientId = `monitor-grad-${title?.replace(/\s/g, '-') || 'default'}-${Math.random().toString(36).substr(2, 9)}`

  // 3 zones: neutral, warning, alert
  const highlights = [
    { start: zones[0], end: zones[1], color: t.neutral },
    { start: zones[1], end: zones[2], color: t.warning },
    { start: zones[2], end: zones[3], color: t.alert }
  ]
  const gridLines = [0, 50, 100]

  return (
    <div
      className="rounded-md overflow-hidden"
      style={{
        backgroundColor: t.bg,
        boxShadow: `inset 0 0 0 1px ${t.border}`
      }}
    >
      <div className="px-3.5 pt-3 pb-2.5">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-3">
            <h3
              className="font-mono"
              style={{
                color: t.titleColor,
                fontSize: '13px',
                fontWeight: '600',
              }}
            >
              {title}
            </h3>
            <div className="flex items-center gap-1.5 font-mono" style={{ fontSize: '12px' }}>
              <span style={{ color: t.metaColor }}>{metric}</span>
              <span style={{ color: t.dimColor }}>·</span>
              <span
                className="tabular-nums"
                style={{ color: t.valueColor, fontWeight: '600' }}
              >
                {value}%
              </span>
              <span style={{ color: t.metaColor }}>used</span>
              <span style={{ color: t.dimColor }}>·</span>
              <span style={{ color: t.dimColor }}>{region}</span>
            </div>
          </div>
          <span
            className="tabular-nums font-mono"
            style={{ color: t.dimColor, fontSize: '11px' }}
          >
            {timeRange}
          </span>
        </div>
      </div>
      {/* Separator */}
      <div style={{ height: '1px', backgroundColor: t.separatorColor }} />
      <div className="relative overflow-hidden">
        <svg viewBox={`0 0 200 ${chartHeight}`} className="w-full h-12 block" preserveAspectRatio="none">
          <defs>
            <linearGradient id={gradientId} x1="0" y1="0" x2="0" y2="1">
              <stop offset="0%" stopColor={t.areaColor || t.lineColor} stopOpacity={t.areaFillTop} />
              <stop offset="100%" stopColor={t.areaColor || t.lineColor} stopOpacity={t.areaFillBottom} />
            </linearGradient>
          </defs>
          {highlights.map((h, i) => (
            <rect key={i} x={h.start * 200} y={0} width={(h.end - h.start) * 200} height={chartHeight} fill={h.color} />
          ))}
          {gridLines.map((pct) => (
            <line
              key={pct}
              x1="0" y1={toY(pct)} x2="200" y2={toY(pct)}
              stroke={pct === 50 ? t.gridDashColor : t.gridColor}
              strokeWidth="1"
              strokeDasharray={pct === 50 ? "2,3" : "none"}
              opacity={pct === 50 ? "0.5" : "0.8"}
            />
          ))}
          <path d={areaPath} fill={`url(#${gradientId})`} />
          <path d={linePath} fill="none" stroke={t.lineColor} strokeWidth="1.5" strokeLinecap="round" vectorEffect="non-scaling-stroke" />
        </svg>
      </div>
    </div>
  )
}

// Multiple choice component - terminal style
const MultipleChoice = ({ question, options, onSelect, selectedId, disabled = false }) => {
  const hasSelection = selectedId !== undefined && selectedId !== null

  return (
    <div className="bg-zinc-900 p-4 font-mono">
      {question && (
        <div className="text-[15px] text-emerald-400">
          {question}
        </div>
      )}
      {options && options.length > 0 && (
        <div className="space-y-0 mt-3">
          {options.map((option, idx) => {
            const optionId = option.id !== undefined ? option.id : idx
            const isSelected = selectedId === optionId
            const isDisabled = disabled || (hasSelection && !isSelected)
            const canInteract = !disabled && !hasSelection
            // Display thought (internal thinking), send message (Slack message)
            const displayText = option.thought || option.text
            const messageText = option.message || option.text

            return (
              <label
                key={optionId}
                className={`flex items-center py-2 px-2.5 rounded ${
                  isSelected
                    ? 'bg-emerald-900/40'
                    : isDisabled
                      ? 'opacity-50 cursor-default'
                      : 'cursor-pointer hover:bg-zinc-800'
                }`}
                onClick={() => canInteract && onSelect?.(optionId, messageText)}
              >
                <div className={`w-4 h-4 rounded-full border-2 flex items-center justify-center flex-shrink-0 ${
                  isSelected 
                    ? 'border-emerald-500 bg-emerald-500' 
                    : 'border-zinc-500 bg-transparent'
                }`}>
                  {isSelected && <div className="w-1.5 h-1.5 rounded-full bg-white" />}
                </div>
                <span className="ml-3 text-white text-[14px]">{displayText}</span>
              </label>
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
export const Message = ({ message, onSelect, threadReplies }) => {
  const { author, components, reactions, thread, created_at, updated_at, isSystem } = message
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

      case 'monitor':
        return (
          <Monitor
            key={index}
            title={component.title}
            metric={component.metric}
            value={component.value}
            theme={component.theme}
            dataPoints={component.dataPoints}
            zoneBreaks={component.zoneBreaks}
            region={component.region}
            timeRange={component.timeRange}
          />
        )


      case 'text':
      default:
        return (
          <div key={index} className="text-[#1d1c1d] dark:text-zinc-200 text-[15px] whitespace-pre-wrap">
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
          <div className="text-[#1d1c1d] dark:text-zinc-200 text-[15px] whitespace-pre-wrap">
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
        <img src={avatar} alt="" className="w-10 h-10 rounded-full flex-shrink-0" />
      ) : (
        <div className="w-10 h-10 rounded-full flex-shrink-0 bg-zinc-200 dark:bg-zinc-700 flex items-center justify-center text-zinc-500 dark:text-zinc-400 text-sm font-medium">
          {name?.[0]?.toUpperCase() || '?'}
        </div>
      )}
      <div className="flex-1 min-w-0">
        {(name || timeStr || isEdited) && (
          <div className="flex items-baseline gap-2 flex-wrap">
            {name && (
              <span className="font-semibold text-[#1d1c1d] dark:text-zinc-100 text-[15px] tracking-[-0.01em]">
                {name}
              </span>
            )}
            {status && (
              <span className="text-[12px] text-zinc-500 dark:text-zinc-400">{status.emoji} {status.text}</span>
            )}
            {timeStr && (
              <span className="text-[#616061] dark:text-zinc-500 text-[12px]">{timeStr}</span>
            )}
            {isEdited && (
              <span className="text-[#616061] dark:text-zinc-500 text-[11px]">(edited)</span>
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
        {computedThread && computedThread.length > 0 && (
          <ThreadReplies replies={computedThread} />
        )}
      </div>
    </div>
  )

  return messageContent
}

// Export helper components for direct use
export { Code, Mention, EmojiReaction, ThreadReplies, Diff, CodeBlock, MultipleChoice, AlertBlock }
export default Message