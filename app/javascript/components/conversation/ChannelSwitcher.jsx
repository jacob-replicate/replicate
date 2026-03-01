import React, { useState, useRef, useEffect } from 'react'

const ChannelItem = ({ item, isActive, onSelect, onClose }) => {
  const hasUnread = item.unreadCount > 0 && !isActive

  return (
    <button
      onClick={() => onSelect(item.id)}
      className={`w-full text-left px-4 py-2 flex items-center gap-2.5 text-[14px] ${
        isActive
          ? 'bg-[rgb(45,48,58)] text-[rgb(190,195,210)]'
          : item.isMuted
            ? 'text-zinc-600'
            : hasUnread
              ? 'text-zinc-50 font-medium hover:bg-zinc-800/50'
              : 'text-zinc-500 hover:text-zinc-300'
      }`}
    >
      {item.isPrivate && (
        <svg className="w-3 h-3 flex-shrink-0 opacity-50" fill="currentColor" viewBox="0 0 16 16">
          <path d="M8 1a2 2 0 0 1 2 2v4H6V3a2 2 0 0 1 2-2zm3 6V3a3 3 0 0 0-6 0v4a2 2 0 0 0-2 2v5a2 2 0 0 0 2 2h6a2 2 0 0 0 2-2V9a2 2 0 0 0-2-2z"/>
        </svg>
      )}

      <span className={`truncate flex-1 ${hasUnread ? 'font-medium' : ''}`}>
        {item.name}
      </span>

      <span className="w-4 h-4 flex items-center justify-center flex-shrink-0">
        {isActive && onClose && (
          <span
            role="button"
            onClick={(e) => {
              e.stopPropagation()
              onClose(item.id)
            }}
            className="w-4 h-4 rounded-full flex items-center justify-center text-zinc-400 hover:text-zinc-300 hover:bg-zinc-700"
          >
            <svg className="w-2.5 h-2.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
            </svg>
          </span>
        )}

        {/* Unread indicator - subtle dot */}
        {hasUnread && !item.isMuted && !isActive && (
          <span className="w-2 h-2 rounded-full bg-red-500" />
        )}
      </span>
    </button>
  )
}

const ChannelList = ({ channels, activeChannelId, onSelect, onClose }) => {
  // Sort channels: unmuted first, then by name
  const sortedChannels = [...channels].sort((a, b) => {
    if (a.isMuted !== b.isMuted) return a.isMuted ? 1 : -1
    return a.name.localeCompare(b.name)
  })

  return (
    <div className="flex-1 overflow-y-auto pb-2 [&::-webkit-scrollbar]:hidden [-ms-overflow-style:none] [scrollbar-width:none]">
      {sortedChannels.map((channel) => (
        <ChannelItem
          key={channel.id}
          item={channel}
          isActive={activeChannelId === channel.id}
          onSelect={onSelect}
          onClose={onClose}
        />
      ))}
    </div>
  )
}


const ChannelSwitcher = ({
  channels,
  activeChannelId,
  onChannelSelect,
  children,
}) => {
  const [sidebarOpen, setSidebarOpen] = useState(false)
  const [closedChannels, setClosedChannels] = useState(() => {
    const saved = localStorage.getItem('closed-channels')
    return saved ? JSON.parse(saved) : []
  })

  // Filter out closed channels
  const visibleChannels = channels.filter(c => !closedChannels.includes(c.id))

  const handleChannelSelect = (channelId) => {
    onChannelSelect(channelId)
    setSidebarOpen(false) // Close sidebar on mobile after selection
  }

  const activeChannel = channels.find(c => c.id === activeChannelId)
  const activeChannelName = activeChannel?.name || 'channel'

  return (
    <div className="flex flex-col bg-zinc-950 overflow-hidden text-sm h-full w-full relative">

      {/* Full-width header */}
      <div className="flex-shrink-0 flex items-center justify-between px-5 py-2 border-b bg-[#16181d] border-[#252830]">
        <div className="flex items-center gap-3">
          {/* Mobile menu button */}
          <button
            onClick={() => setSidebarOpen(true)}
            className="md:hidden text-[#6b7080] hover:text-[#e8e9ed] transition-colors duration-200 mr-1"
          >
            <svg className="w-5 h-5" fill="none" stroke="currentColor" strokeWidth={1.5} viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" d="M3.75 6.75h16.5M3.75 12h16.5M3.75 17.25h16.5" />
            </svg>
          </button>
          {/* Wordmark */}
          <div className="flex items-center gap-4">
            <a href="/" className="text-zinc-100 text-[15px] tracking-[0.08em] uppercase font-light hover:text-zinc-300 transition-colors">
              Invariant
            </a>
            <span className="text-[#8B9099] text-[13px] tracking-[0.02em] font-light hidden md:inline">
              Reason through distributed system failures. The LLM points out what you missed.
            </span>
          </div>
        </div>
        <div className="flex items-center gap-5">
          {/* Navigation links */}
          <nav className="hidden md:flex items-center gap-5 text-[11px] tracking-[0.04em] uppercase">
            <a href="/about" className="text-[#9ca3af] hover:text-[#e5e7eb] transition-colors duration-200">About</a>
            <a href="/security" className="text-[#9ca3af] hover:text-[#e5e7eb] transition-colors duration-200">Security</a>
            <a href="/privacy" className="text-[#9ca3af] hover:text-[#e5e7eb] transition-colors duration-200">Privacy</a>
            <a href="/terms" className="text-[#9ca3af] hover:text-[#e5e7eb] transition-colors duration-200">Terms</a>
          </nav>

          {/* Divider */}
          <div className="hidden md:block w-px h-4 bg-[#374151]"></div>

          {/* Google Sign In */}
          <form action="/auth/google_oauth2" method="post">
            <input type="hidden" name="authenticity_token" value={document.querySelector('meta[name="csrf-token"]')?.content || ''} />
            <button
              type="submit"
              className="inline-flex items-center gap-2 px-3 py-1.5 text-[12px] tracking-[0.01em] text-white bg-[#5b52e8] border border-[#818cf8] rounded-md hover:bg-[#4f46e5] transition-all duration-200"
            >
              <svg className="w-3.5 h-3.5" viewBox="0 0 24 24">
                <path fill="currentColor" fillOpacity="0.9" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
                <path fill="currentColor" fillOpacity="0.7" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
                <path fill="currentColor" fillOpacity="0.5" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/>
                <path fill="currentColor" fillOpacity="0.6" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
              </svg>
              <span>Sign in</span>
            </button>
          </form>
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
          bg-[rgb(39,39,42)] 
          border-r border-zinc-800 
          flex flex-col
          md:h-full
        `}>
          <ChannelList
            channels={visibleChannels}
            activeChannelId={activeChannelId}
            onSelect={handleChannelSelect}
            onClose={(channelId) => {
              // Add to closed channels
              const newClosed = [...closedChannels, channelId]
              setClosedChannels(newClosed)
              localStorage.setItem('closed-channels', JSON.stringify(newClosed))

              // Switch to next available channel
              const remaining = visibleChannels.filter(c => c.id !== channelId)
              if (remaining.length > 0) {
                handleChannelSelect(remaining[0].id)
              }
            }}
          />

          {/* Footer links - only on mobile since navbar hides them there */}
          <div className="md:hidden flex-shrink-0 border-t border-zinc-800 px-4 py-3 flex justify-center items-center text-[13px] text-zinc-500">
            <a href="/about" className="hover:text-zinc-300 transition-colors">About</a>
            <span className="mx-2 text-zinc-600">·</span>
            <a href="/privacy" className="hover:text-zinc-300 transition-colors">Privacy</a>
            <span className="mx-2 text-zinc-600">·</span>
            <a href="/terms" className="hover:text-zinc-300 transition-colors">Terms</a>
            <span className="mx-2 text-zinc-600">·</span>
            <a href="/security" className="hover:text-zinc-300 transition-colors">Security</a>
          </div>
        </div>

        {/* Main content area */}
        <div className="flex-1 flex flex-col min-w-0 min-h-0 bg-zinc-950">
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