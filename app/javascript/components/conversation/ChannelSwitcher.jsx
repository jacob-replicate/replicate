import React, { useState, useRef, useEffect } from 'react'

/**
 * ChannelButton - Reusable button for channel/DM list items
 */
const ChannelButton = ({ channel, activeChannelId, onSelect, showHash = true }) => {
  const isActive = activeChannelId === channel.id
  const hasUnread = channel.unreadCount > 0 && !isActive

  return (
    <button
      onClick={() => onSelect(channel.id)}
      className={`w-full text-left px-3 py-1.5 flex items-center gap-2 hover:bg-zinc-200/50 dark:hover:bg-zinc-700/50 ${
        isActive
          ? 'bg-zinc-200 dark:bg-zinc-700 text-zinc-900 dark:text-white'
          : 'text-zinc-600 dark:text-zinc-400'
      }`}
    >

      <span className="truncate">{showHash ? '#' : ''}{channel.name}</span>

      {/* Unread count */}
      {hasUnread && (
        <span className="ml-auto text-xs bg-indigo-500/20 text-indigo-600 dark:text-indigo-400 px-1.5 rounded">
          {channel.unreadCount}
        </span>
      )}
    </button>
  )
}

/**
 * ChannelSwitcher - Tool for switching between multiple chat channels
 *
 * IRC-inspired channel list sidebar that can wrap any conversation content.
 */
const ChannelSwitcher = ({
  channels = [],
  activeChannelId,
  onChannelSelect,
  children,
}) => {
  const [isDark, setIsDark] = useState(() => {
    return document.documentElement.classList.contains('dark')
  })
  const [sidebarOpen, setSidebarOpen] = useState(false)
  const [bannerDismissed, setBannerDismissed] = useState(() => {
    return localStorage.getItem('training-banner-dismissed') === 'true'
  })

  const toggleDarkMode = () => {
    const newDark = !isDark
    setIsDark(newDark)
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

  return (
    <div className="flex bg-zinc-100 dark:bg-zinc-800 overflow-hidden text-sm h-full w-full relative">

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
        z-50 md:z-auto
        w-64 flex-shrink-0 
        bg-zinc-100 dark:bg-zinc-800 
        border-r border-zinc-300 dark:border-zinc-700 
        flex flex-col
        h-full
        transition-transform duration-200 ease-in-out
      `}>
        {/* Channel list */}
        <div className="flex-1 overflow-y-auto py-2">
          {/* Incidents section */}
          <div className="px-3 py-1 text-zinc-500 text-xs uppercase tracking-wider flex items-center justify-between">
            <span>Incidents</span>
            <button
              className="flex items-center gap-1 text-[10px] font-medium text-emerald-600 dark:text-emerald-400 hover:text-emerald-700 dark:hover:text-emerald-300 bg-emerald-50 dark:bg-emerald-900/30 hover:bg-emerald-100 dark:hover:bg-emerald-900/50 px-1.5 py-0.5 rounded transition-colors"
              onClick={() => alert('New incident flow coming soon!')}
            >
              <svg className="w-3 h-3" viewBox="0 0 16 16" fill="currentColor">
                <path d="M8 4a.5.5 0 0 1 .5.5v3h3a.5.5 0 0 1 0 1h-3v3a.5.5 0 0 1-1 0v-3h-3a.5.5 0 0 1 0-1h3v-3A.5.5 0 0 1 8 4z"/>
              </svg>
              New
            </button>
          </div>
          {channels.filter(c => c.id.startsWith('inc-')).map((channel) => (
            <ChannelButton
              key={channel.id}
              channel={channel}
              activeChannelId={activeChannelId}
              onSelect={handleChannelSelect}
              showHash
            />
          ))}

          {/* Ops section */}
          <div className="px-3 py-1 mt-3 text-zinc-500 text-xs uppercase tracking-wider">Ops</div>
          {channels.filter(c => ['ops-alerts', 'oncall', 'deploy-prod', 'deploy-staging'].includes(c.id)).map((channel) => (
            <ChannelButton
              key={channel.id}
              channel={channel}
              activeChannelId={activeChannelId}
              onSelect={handleChannelSelect}
              showHash
            />
          ))}

          {/* Teams section */}
          <div className="px-3 py-1 mt-3 text-zinc-500 text-xs uppercase tracking-wider">Teams</div>
          {channels.filter(c => ['platform-eng', 'backend', 'frontend', 'infra', 'sre-team', 'security'].includes(c.id)).map((channel) => (
            <ChannelButton
              key={channel.id}
              channel={channel}
              activeChannelId={activeChannelId}
              onSelect={handleChannelSelect}
              showHash
            />
          ))}

          {/* General section */}
          <div className="px-3 py-1 mt-3 text-zinc-500 text-xs uppercase tracking-wider">General</div>
          {channels.filter(c => ['engineering', 'random', 'watercooler'].includes(c.id)).map((channel) => (
            <ChannelButton
              key={channel.id}
              channel={channel}
              activeChannelId={activeChannelId}
              onSelect={handleChannelSelect}
              showHash
            />
          ))}

          {/* DMs section */}
          <div className="px-3 py-1 mt-3 text-zinc-500 text-xs uppercase tracking-wider">Direct Messages</div>
          {channels.filter(c => c.id.startsWith('dm-')).map((channel) => (
            <ChannelButton
              key={channel.id}
              channel={channel}
              activeChannelId={activeChannelId}
              onSelect={handleChannelSelect}
              showHash={false}
            />
          ))}
        </div>

        {/* Footer with links */}
        <div className="border-t border-zinc-300 dark:border-zinc-700">
          {/* Links */}
          <div className="px-3 py-2 flex flex-wrap gap-x-3 gap-y-1 text-[11px]">
            <a href="/privacy" className="text-zinc-500 hover:text-zinc-700 dark:hover:text-zinc-300 hover:underline">Privacy</a>
            <a href="/terms" className="text-zinc-500 hover:text-zinc-700 dark:hover:text-zinc-300 hover:underline">Terms</a>
            <a href="/security" className="text-zinc-500 hover:text-zinc-700 dark:hover:text-zinc-300 hover:underline">Security</a>
          </div>
        </div>
      </div>

      {/* Main content area */}
      <div className="flex-1 flex flex-col min-w-0 min-h-0 bg-white dark:bg-zinc-900">
        {/* Training mode banner */}
        {!bannerDismissed && (
          <div className="flex-shrink-0 bg-indigo-600 text-white text-xs font-medium px-3 py-1.5 flex items-center justify-center gap-2">
            <span>TRAINING MODE — This is a simulated security incident for learning purposes</span>
            <button
              onClick={() => {
                setBannerDismissed(true)
                localStorage.setItem('training-banner-dismissed', 'true')
              }}
              className="ml-2 hover:bg-indigo-500 rounded p-0.5"
            >
              <svg className="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>
        )}
        {/* Mobile header with menu button */}
        <div className="md:hidden flex-shrink-0 flex items-center gap-2 px-3 py-2 border-b border-zinc-200 dark:border-zinc-700 bg-zinc-100 dark:bg-zinc-800">
          <button
            onClick={() => setSidebarOpen(true)}
            className="text-zinc-600 dark:text-zinc-400 hover:text-zinc-900 dark:hover:text-white"
          >
            <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6h16M4 12h16M4 18h16" />
            </svg>
          </button>
          <span className="text-zinc-600 dark:text-zinc-400 text-xs">#{channels.find(c => c.id === activeChannelId)?.name || 'channel'}</span>
        </div>
        {/* Desktop channel header */}
        <div className="hidden md:flex flex-shrink-0 items-center justify-between px-4 py-2 border-b border-zinc-200 dark:border-zinc-700 bg-white dark:bg-zinc-900">
          <div className="flex items-center gap-2">
            <span className="font-semibold text-zinc-900 dark:text-white text-[15px]">#{channels.find(c => c.id === activeChannelId)?.name || 'channel'}</span>
          </div>
          <div className="flex items-center">
            {/* Segmented dark mode toggle */}
            <div className="flex rounded-md border border-zinc-200 dark:border-zinc-600 overflow-hidden text-xs">
              <button
                onClick={() => { if (isDark) toggleDarkMode() }}
                className={`px-2.5 py-1.5 transition-colors ${!isDark ? 'bg-zinc-100 dark:bg-zinc-700 text-zinc-700 dark:text-zinc-200' : 'text-zinc-400 hover:bg-zinc-50 dark:hover:bg-zinc-800'}`}
              >
                <svg className="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                  <path fillRule="evenodd" d="M10 2a1 1 0 011 1v1a1 1 0 11-2 0V3a1 1 0 011-1zm4 8a4 4 0 11-8 0 4 4 0 018 0zm-.464 4.95l.707.707a1 1 0 001.414-1.414l-.707-.707a1 1 0 00-1.414 1.414zm2.12-10.607a1 1 0 010 1.414l-.706.707a1 1 0 11-1.414-1.414l.707-.707a1 1 0 011.414 0zM17 11a1 1 0 100-2h-1a1 1 0 100 2h1zm-7 4a1 1 0 011 1v1a1 1 0 11-2 0v-1a1 1 0 011-1zM5.05 6.464A1 1 0 106.465 5.05l-.708-.707a1 1 0 00-1.414 1.414l.707.707zm1.414 8.486l-.707.707a1 1 0 01-1.414-1.414l.707-.707a1 1 0 011.414 1.414zM4 11a1 1 0 100-2H3a1 1 0 000 2h1z" clipRule="evenodd" />
                </svg>
              </button>
              <button
                onClick={() => { if (!isDark) toggleDarkMode() }}
                className={`px-2.5 py-1.5 transition-colors ${isDark ? 'bg-zinc-100 dark:bg-zinc-700 text-zinc-700 dark:text-zinc-200' : 'text-zinc-400 hover:bg-zinc-50 dark:hover:bg-zinc-800'}`}
              >
                <svg className="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                  <path d="M17.293 13.293A8 8 0 016.707 2.707a8.001 8.001 0 1010.586 10.586z" />
                </svg>
              </button>
            </div>
          </div>
        </div>
        {/* Children container */}
        <div className="flex-1 min-h-0 flex">
          <div className="flex-1 flex flex-col min-w-0">
            {children}
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

/**
 * IRCInput - Input field styled like IRC
 */
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