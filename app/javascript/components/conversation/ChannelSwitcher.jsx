import React, { useState, useRef, useEffect } from 'react'
import { useConversationContext } from './ConversationContext'

const ChannelItem = ({ item, isActive, onSelect, onClose }) => {
  const hasUnread = item.unreadCount > 0 && !isActive
  const channelId = item.uuid || item.id

  return (
    <button
      onClick={() => onSelect(channelId)}
      className={`w-full text-left px-4 py-2 flex items-center gap-2.5 ${
        isActive
          ? 'bg-[rgb(235,238,245)] dark:bg-[rgb(45,48,58)] text-[rgb(50,55,70)] dark:text-[rgb(190,195,210)]'
          : item.isMuted
            ? 'text-zinc-400 dark:text-zinc-600'
            : hasUnread
              ? 'text-zinc-900 dark:text-zinc-50 font-medium hover:bg-zinc-100 dark:hover:bg-zinc-800/50'
              : 'text-zinc-500 dark:text-zinc-400 hover:text-zinc-900 dark:hover:text-zinc-100'
      }`}
    >
      {/* Lock icon for private channels */}
      {item.isPrivate && (
        <svg className="w-3 h-3 flex-shrink-0 opacity-50" fill="currentColor" viewBox="0 0 16 16">
          <path d="M8 1a2 2 0 0 1 2 2v4H6V3a2 2 0 0 1 2-2zm3 6V3a3 3 0 0 0-6 0v4a2 2 0 0 0-2 2v5a2 2 0 0 0 2 2h6a2 2 0 0 0 2-2V9a2 2 0 0 0-2-2z"/>
        </svg>
      )}

      <span className={`truncate ${hasUnread ? 'font-medium' : ''}`}>
        {item.name}
      </span>

      {/* X button when active */}
      {isActive && onClose && (
        <span
          role="button"
          onClick={(e) => {
            e.stopPropagation()
            onClose(channelId)
          }}
          className="ml-auto w-5 h-5 rounded-full flex items-center justify-center text-zinc-400 hover:text-zinc-600 dark:hover:text-zinc-300 hover:bg-zinc-200 dark:hover:bg-zinc-700"
        >
          <svg className="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
          </svg>
        </span>
      )}

      {/* Unread indicator - circle badge */}
      {hasUnread && !item.isMuted && (
        <span className="ml-auto w-5 h-5 min-w-5 rounded-full bg-red-500 dark:bg-red-500 text-white text-[11px] font-semibold tabular-nums flex items-center justify-center flex-shrink-0">
          {item.unreadCount}
        </span>
      )}
    </button>
  )
}

/**
 * ChannelSection - Renders a section header and its items
 */
const ChannelSection = ({ section, channels, activeChannelId, onSelect, onClose }) => {
  // Filter channels for this section and sort muted to bottom
  // Support both uuid and id in filter functions
  const sectionChannels = channels
    .filter(c => section.filter(c))
    .sort((a, b) => (a.isMuted ? 1 : 0) - (b.isMuted ? 1 : 0))

  if (sectionChannels.length === 0) return null

  return (
    <div className={section.id !== 'incidents' ? '' : ''}>
      <div className="px-4 py-2.5 bg-zinc-300 dark:bg-zinc-700 text-zinc-700 dark:text-zinc-100 text-[13px] font-semibold flex items-center justify-between">
        <span>{section.label}</span>
        {section.action && (
          <button
            className="flex items-center gap-1 text-[11px] text-indigo-500 dark:text-indigo-400 hover:text-indigo-600 dark:hover:text-indigo-300 font-medium transition-colors"
            onClick={section.action.onClick}
          >
            {SectionIcons[section.action.icon]}
            {section.action.label}
          </button>
        )}
      </div>
      {sectionChannels.map((channel) => {
        // Support both uuid and id for active comparison
        const channelId = channel.uuid || channel.id
        return (
          <ChannelItem
            key={channelId}
            item={{
              ...channel,
              prefix: section.prefix ?? '#',
            }}
            isActive={activeChannelId === channelId}
            onSelect={onSelect}
            onClose={onClose}
          />
        )
      })}
    </div>
  )
}

/**
 * ChannelList - Renders all channel sections
 */
const ChannelList = ({ sections, channels, activeChannelId, onSelect, onClose }) => {
  return (
    <div className="flex-1 overflow-y-auto pb-2 [&::-webkit-scrollbar]:hidden [-ms-overflow-style:none] [scrollbar-width:none]">
      {sections.map((section) => (
        <ChannelSection
          key={section.id}
          section={section}
          channels={channels}
          activeChannelId={activeChannelId}
          onSelect={onSelect}
          onClose={onClose}
        />
      ))}
    </div>
  )
}

/**
 * Icon components for section actions
 */
const SectionIcons = {
  plus: (
    <svg className="w-3 h-3" viewBox="0 0 16 16" fill="currentColor">
      <path d="M8 4a.5.5 0 0 1 .5.5v3h3a.5.5 0 0 1 0 1h-3v3a.5.5 0 0 1-1 0v-3h-3a.5.5 0 0 1 0-1h3v-3A.5.5 0 0 1 8 4z"/>
    </svg>
  ),
}

/**
 * ChannelSwitcher - Sidebar for switching between channels and DMs
 *
 * @param {Array} channels - List of channel objects with id, name, section, unreadCount, isPrivate, isMuted
 * @param {Array} sections - List of section configs with id, label, filter function, optional prefix and action
 * @param {string} activeChannelId - Currently selected channel ID
 * @param {function} onChannelSelect - Callback when a channel is selected
 * @param {ReactNode} children - Content to render in main area
 */
const ChannelSwitcher = ({
  channels,
  sections,
  activeChannelId,
  onChannelSelect,
  children,
}) => {
  // Try to use context for dark mode, fallback to local state for standalone usage
  let contextValue = null
  try {
    contextValue = useConversationContext()
  } catch (e) {
    // Context not available, will use local state
  }

  // Dark mode - prefer context, fallback to local state
  const [localIsDark, setLocalIsDark] = useState(() => {
    return document.documentElement.classList.contains('dark')
  })
  const isDark = contextValue?.isDarkMode ?? localIsDark
  const setIsDark = contextValue?.setIsDarkMode ?? setLocalIsDark

  const [sidebarOpen, setSidebarOpen] = useState(false)
  const [closedChannels, setClosedChannels] = useState(() => {
    const saved = localStorage.getItem('closed-channels')
    return saved ? JSON.parse(saved) : []
  })

  // Filter out closed channels
  const visibleChannels = channels.filter(c => !closedChannels.includes(c.uuid || c.id))

  const toggleDarkMode = () => {
    const newDark = !isDark
    setIsDark(newDark)
    // Always sync to DOM and localStorage
    if (newDark) {
      document.documentElement.classList.add('dark')
      localStorage.setItem('theme', 'dark')
    } else {
      document.documentElement.classList.remove('dark')
      localStorage.setItem('theme', 'light')
    }
  }

  const handleChannelSelect = (channelId) => {
    onChannelSelect(channelId)
    setSidebarOpen(false) // Close sidebar on mobile after selection
  }

  const activeChannel = channels.find(c => (c.uuid || c.id) === activeChannelId)
  const activeChannelName = activeChannel?.name || 'channel'

  return (
    <div className="flex flex-col bg-white dark:bg-zinc-950 overflow-hidden text-sm h-full w-full relative">

      {/* Full-width header */}
      <div className="flex-shrink-0 flex items-center justify-between px-4 py-2 border-b border-[rgb(50,50,54)] bg-[rgb(39,39,42)]">
        <div className="flex items-center gap-2">
          {/* Mobile menu button */}
          <button
            onClick={() => setSidebarOpen(true)}
            className="md:hidden text-zinc-400 hover:text-zinc-100 transition-colors mr-1"
          >
            <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6h16M4 12h16M4 18h16" />
            </svg>
          </button>
          {/* Wordmark */}
          <div className="flex items-center gap-4">
            <a href="/" className="text-zinc-100 text-[15px] tracking-[0.15em] uppercase font-light hover:text-zinc-300 transition-colors">Invariant</a>
            <span className="text-[#F5D77A] text-[13px] tracking-[0.04em] font-light hidden md:inline">
              Hard SRE drills that expose fragile mental models (before production does)
            </span>
          </div>
        </div>
        <div className="flex items-center gap-4">
          {/* Navigation links */}
          <nav className="hidden md:flex items-center gap-5 text-[13px] text-zinc-400">
            <a href="/about" className="hover:text-zinc-200 transition-colors">About</a>
            <a href="/security" className="hover:text-zinc-200 transition-colors">Security</a>
            <a href="/privacy" className="hover:text-zinc-200 transition-colors">Privacy</a>
            <a href="/terms" className="hover:text-zinc-200 transition-colors">Terms</a>
          </nav>
          {/* Google Sign In */}
          <form action="/auth/google_oauth2" method="post">
            <input type="hidden" name="authenticity_token" value={document.querySelector('meta[name="csrf-token"]')?.content || ''} />
            <button type="submit" className="inline-flex items-center gap-2 px-3 py-1.5 text-[13px] font-medium text-zinc-300 bg-zinc-800 border border-zinc-700 rounded-md hover:bg-zinc-700 transition-colors">
              <svg className="w-4 h-4" viewBox="0 0 24 24">
                <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
                <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
                <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/>
                <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
              </svg>
              <span>Sign in</span>
            </button>
          </form>
          {/* Debug: Clear localStorage */}
          <button
            onClick={() => {
              localStorage.clear()
              window.location.reload()
            }}
            className="px-2 py-1.5 text-[11px] text-zinc-500 hover:text-zinc-300 hover:bg-zinc-800 rounded transition-colors"
            title="Clear all localStorage and reload"
          >
            Reset
          </button>
          {/* Segmented dark mode toggle */}
          <div className="flex rounded-md border border-zinc-700 overflow-hidden text-xs">
            <button
              onClick={() => { if (isDark) toggleDarkMode() }}
              className={`px-2.5 py-1.5 transition-colors ${!isDark ? 'bg-zinc-700 text-zinc-100' : 'text-zinc-400 hover:bg-zinc-800'}`}
            >
              <svg className="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                <path fillRule="evenodd" d="M10 2a1 1 0 011 1v1a1 1 0 11-2 0V3a1 1 0 011-1zm4 8a4 4 0 11-8 0 4 4 0 018 0zm-.464 4.95l.707.707a1 1 0 001.414-1.414l-.707-.707a1 1 0 00-1.414 1.414zm2.12-10.607a1 1 0 010 1.414l-.706.707a1 1 0 11-1.414-1.414l.707-.707a1 1 0 011.414 0zM17 11a1 1 0 100-2h-1a1 1 0 100 2h1zm-7 4a1 1 0 011 1v1a1 1 0 11-2 0v-1a1 1 0 011-1zM5.05 6.464A1 1 0 106.465 5.05l-.708-.707a1 1 0 00-1.414 1.414l.707.707zm1.414 8.486l-.707.707a1 1 0 01-1.414-1.414l.707-.707a1 1 0 011.414 1.414zM4 11a1 1 0 100-2H3a1 1 0 000 2h1z" clipRule="evenodd" />
              </svg>
            </button>
            <button
              onClick={() => { if (!isDark) toggleDarkMode() }}
              className={`px-2.5 py-1.5 transition-colors ${isDark ? 'bg-zinc-700 text-zinc-100' : 'text-zinc-400 hover:bg-zinc-800'}`}
            >
              <svg className="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                <path d="M17.293 13.293A8 8 0 016.707 2.707a8.001 8.001 0 1010.586 10.586z" />
              </svg>
            </button>
          </div>
        </div>
      </div>

      {/* Main layout with sidebar and content */}
      <div className="flex flex-1 min-h-0 overflow-hidden">
        {/* Mobile overlay */}
        {sidebarOpen && (
          <div
            className="md:hidden fixed inset-0 bg-black/50 z-40"
            onClick={() => setSidebarOpen(false)}
          />
        )}

        {/* Channel sidebar - hidden on mobile unless open */}
        <div className={`
          ${sidebarOpen ? 'translate-x-0' : '-translate-x-full'} 
          md:translate-x-0
          fixed md:relative
          top-0 bottom-0 md:top-auto md:bottom-auto
          z-50 md:z-auto
          w-64
          flex-shrink-0 
          bg-[rgb(245,245,247)] dark:bg-[rgb(39,39,42)] 
          border-r border-zinc-200 dark:border-zinc-800 
          flex flex-col
          md:h-full
        `}>
          <ChannelList
            sections={sections}
            channels={visibleChannels}
            activeChannelId={activeChannelId}
            onSelect={handleChannelSelect}
            onClose={(channelId) => {
              // Add to closed channels
              const newClosed = [...closedChannels, channelId]
              setClosedChannels(newClosed)
              localStorage.setItem('closed-channels', JSON.stringify(newClosed))

              // Switch to next available channel
              const remaining = visibleChannels.filter(c => (c.uuid || c.id) !== channelId)
              if (remaining.length > 0) {
                handleChannelSelect(remaining[0].uuid || remaining[0].id)
              }
            }}
          />

          {/* Footer links - only on mobile since navbar hides them there */}
          <div className="md:hidden flex-shrink-0 border-t border-zinc-200 dark:border-zinc-800 px-4 py-3 flex justify-center items-center text-[13px] text-zinc-400 dark:text-zinc-500">
            <a href="/about" className="hover:text-zinc-600 dark:hover:text-zinc-300 transition-colors">About</a>
            <span className="mx-2 text-zinc-300 dark:text-zinc-600">·</span>
            <a href="/privacy" className="hover:text-zinc-600 dark:hover:text-zinc-300 transition-colors">Privacy</a>
            <span className="mx-2 text-zinc-300 dark:text-zinc-600">·</span>
            <a href="/terms" className="hover:text-zinc-600 dark:hover:text-zinc-300 transition-colors">Terms</a>
            <span className="mx-2 text-zinc-300 dark:text-zinc-600">·</span>
            <a href="/security" className="hover:text-zinc-600 dark:hover:text-zinc-300 transition-colors">Security</a>
          </div>
        </div>

        {/* Main content area */}
        <div className="flex-1 flex flex-col min-w-0 min-h-0 bg-white dark:bg-zinc-950">
          {/* Children container */}
          <div className="flex-1 min-h-0 flex">
            <div className="flex-1 flex flex-col min-w-0">
              {children}
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

export default ChannelSwitcher

/**
 * IRCHeader - Topic bar for the active channel
 */
export const IRCHeader = ({ channelName, topic, userCount }) => {
  return (
    <div className="bg-zinc-900 border-b border-zinc-800 px-3 py-2 flex items-center gap-3">
      <span className="text-white font-medium">#{channelName}</span>
      {topic && (
        <>
          <span className="text-zinc-600">|</span>
          <span className="text-zinc-400 truncate flex-1">{topic}</span>
        </>
      )}
      {userCount && (
        <span className="text-zinc-500 text-xs">{userCount} users</span>
      )}
    </div>
  )
}

/**
 * IRCMessage - IRC-style message format
 * Format: [HH:MM] <nick> message
 */
export const IRCMessageFormat = ({ timestamp, nick, message, isAction = false }) => {
  const time = new Date(timestamp).toLocaleTimeString('en-US', {
    hour: '2-digit',
    minute: '2-digit',
    hour12: false
  })

  if (isAction) {
    return (
      <div className="px-3 py-0.5 hover:bg-zinc-800/30">
        <span className="text-zinc-500">[{time}]</span>
        <span className="text-purple-400"> * {nick}</span>
        <span className="text-zinc-300"> {message}</span>
      </div>
    )
  }

  return (
    <div className="px-3 py-0.5 hover:bg-zinc-800/30">
      <span className="text-zinc-500">[{time}]</span>
      <span className="text-cyan-400"> &lt;{nick}&gt;</span>
      <span className="text-zinc-200"> {message}</span>
    </div>
  )
}

/**
 * IRCSystemMessage - Join/part/mode messages
 */
export const IRCSystemMessage = ({ timestamp, message, type = 'info' }) => {
  const time = new Date(timestamp).toLocaleTimeString('en-US', {
    hour: '2-digit',
    minute: '2-digit',
    hour12: false
  })

  const colors = {
    join: 'text-green-400',
    part: 'text-red-400',
    mode: 'text-yellow-400',
    info: 'text-zinc-500',
  }

  return (
    <div className="px-3 py-0.5">
      <span className="text-zinc-500">[{time}]</span>
      <span className={colors[type]}> *** {message}</span>
    </div>
  )
}

export const IRCInput = ({ channelName, onSend }) => {
  const [value, setValue] = useState('')
  const inputRef = useRef(null)

  const handleSubmit = (e) => {
    e.preventDefault()
    if (value.trim()) {
      onSend(value)
      setValue('')
    }
  }

  return (
    <form onSubmit={handleSubmit} className="border-t border-zinc-800 bg-zinc-950">
      <div className="flex items-center px-3 py-2 gap-2">
        <span className="text-zinc-500">[#{channelName}]</span>
        <input
          ref={inputRef}
          type="text"
          value={value}
          onChange={(e) => setValue(e.target.value)}
          className="flex-1 bg-transparent text-zinc-200 outline-none placeholder-zinc-600"
          placeholder="Type a message..."
        />
      </div>
    </form>
  )
}