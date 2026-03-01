import React, { useState } from 'react'

const ChannelItem = ({ item, isActive, onSelect, onClose }) => {
  const hasUnread = item.unreadCount > 0 && !isActive

  return (
    <button
      onClick={() => onSelect(item.id)}
      className="w-full text-left px-4 py-2 flex items-center gap-2.5 text-[14px]"
      style={{
        backgroundColor: isActive ? '#252529' : 'transparent',
        borderLeft: isActive ? '5px solid #8b5cf6' : '5px solid transparent',
        color: isActive
          ? '#e4e4e7'
          : item.isMuted
            ? '#52525b'
            : hasUnread
              ? '#fafafa'
              : '#71717a',
        fontWeight: isActive || hasUnread ? 500 : 400,
      }}
      onMouseEnter={(e) => {
        if (!isActive) e.currentTarget.style.backgroundColor = '#1a1a1c'
      }}
      onMouseLeave={(e) => {
        if (!isActive) e.currentTarget.style.backgroundColor = 'transparent'
      }}
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
    <div className="flex flex-col overflow-hidden text-sm h-full w-full relative" style={{ backgroundColor: '#18181b' }}>

      {/* Full-width header */}
      <div className="flex-shrink-0 flex items-center justify-between px-5 py-2" style={{ backgroundColor: '#131316' }}>
        <div className="flex items-center gap-3">
          {/* Mobile: tappable header that toggles sidebar */}
          <button
            onClick={() => setSidebarOpen(!sidebarOpen)}
            className="flex items-center gap-1.5 md:hidden"
          >
            <span className="text-zinc-100 text-[15px] font-light">Invariant</span>
            <span style={{ color: '#52525b' }}>/</span>
            <span className="text-[15px] font-medium" style={{ color: '#e4e4e7' }}>{activeChannelName}</span>
            <svg
              className="w-4 h-4 ml-0.5"
              style={{ color: '#71717a', transform: sidebarOpen ? 'rotate(180deg)' : 'none' }}
              fill="none"
              stroke="currentColor"
              strokeWidth={2}
              viewBox="0 0 24 24"
            >
              <path strokeLinecap="round" strokeLinejoin="round" d="M19 9l-7 7-7-7" />
            </svg>
          </button>
          {/* Desktop: wordmark + tagline */}
          <div className="hidden md:flex md:items-center gap-4">
            <a href="/" className="text-zinc-100 text-[15px] tracking-[0.08em] uppercase font-light hover:text-zinc-300 transition-colors">
              Invariant
            </a>
            {/* Desktop tagline - hidden on tablet */}
            <span className="text-[#8B9099] text-[13px] tracking-[0.02em] font-light hidden lg:inline">
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

        {/* Channel sidebar - always visible on desktop */}
        <div
          className="hidden md:flex md:w-64 flex-shrink-0 flex-col"
          style={{ backgroundColor: '#19191c' }}
        >
          <ChannelList
            channels={visibleChannels}
            activeChannelId={activeChannelId}
            onSelect={handleChannelSelect}
            onClose={(channelId) => {
              const newClosed = [...closedChannels, channelId]
              setClosedChannels(newClosed)
              localStorage.setItem('closed-channels', JSON.stringify(newClosed))
              const remaining = visibleChannels.filter(c => c.id !== channelId)
              if (remaining.length > 0) {
                handleChannelSelect(remaining[0].id)
              }
            }}
          />
        </div>

        {/* Mobile: show either channel list OR content */}
        {sidebarOpen ? (
          <div className="flex-1 flex flex-col md:hidden" style={{ backgroundColor: '#19191c' }}>
            <ChannelList
              channels={visibleChannels}
              activeChannelId={activeChannelId}
              onSelect={handleChannelSelect}
              onClose={null}
            />
            {/* Footer links */}
            <div className="flex-shrink-0 border-t px-4 py-3 flex justify-center items-center text-[13px]" style={{ borderColor: '#232326', color: '#71717a' }}>
              <a href="/about" className="hover:text-zinc-300 transition-colors">About</a>
              <span className="mx-2" style={{ color: '#3f3f46' }}>·</span>
              <a href="/privacy" className="hover:text-zinc-300 transition-colors">Privacy</a>
              <span className="mx-2" style={{ color: '#3f3f46' }}>·</span>
              <a href="/terms" className="hover:text-zinc-300 transition-colors">Terms</a>
              <span className="mx-2" style={{ color: '#3f3f46' }}>·</span>
              <a href="/security" className="hover:text-zinc-300 transition-colors">Security</a>
            </div>
          </div>
        ) : (
          <div className="flex-1 flex flex-col min-w-0 min-h-0 md:hidden" style={{ backgroundColor: '#1c1c20' }}>
            {children}
          </div>
        )}

        {/* Desktop: always show content */}
        <div className="hidden md:flex flex-1 flex-col min-w-0 min-h-0" style={{ backgroundColor: '#1c1c20' }}>
          {children}
        </div>
      </div>
    </div>
  )
}

export default ChannelSwitcher