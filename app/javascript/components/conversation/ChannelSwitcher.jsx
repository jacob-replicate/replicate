import React, { useState, useRef, useEffect, useLayoutEffect } from 'react'

/**
 * UserMenu - Profile photo with dropdown for sign out
 */
const UserMenu = ({ user }) => {
  const [isOpen, setIsOpen] = useState(false)
  const menuRef = useRef(null)

  // Close dropdown when clicking outside
  useEffect(() => {
    const handleClickOutside = (e) => {
      if (menuRef.current && !menuRef.current.contains(e.target)) {
        setIsOpen(false)
      }
    }
    document.addEventListener('mousedown', handleClickOutside)
    return () => document.removeEventListener('mousedown', handleClickOutside)
  }, [])

  return (
    <div className="relative" ref={menuRef}>
      <button
        type="button"
        onClick={() => setIsOpen(!isOpen)}
        className="flex items-center gap-1"
      >
        <img
          src={user.avatar_url}
          className="w-[26px] h-[26px] rounded-full ring-1 ring-zinc-700/80"
          style={{ filter: 'brightness(0.92)' }}
          alt={user.name}
          referrerPolicy="no-referrer"
        />
        <svg className="w-3 h-3 text-zinc-400" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" d="M19 9l-7 7-7-7" />
        </svg>
      </button>
      {isOpen && (
        <div className="absolute right-0 mt-2 bg-zinc-800 border border-zinc-700 rounded-lg shadow-lg py-1 z-50 min-w-[180px]">
          <div className="px-3 py-2 border-b border-zinc-700">
            <p className="text-sm font-medium text-zinc-100 whitespace-nowrap">{user.name}</p>
            <p className="text-xs text-zinc-400 whitespace-nowrap">{user.email}</p>
          </div>
          <form action="/logout" method="post">
            <input type="hidden" name="_method" value="delete" />
            <input type="hidden" name="authenticity_token" value={document.querySelector('meta[name="csrf-token"]')?.content || ''} />
            <button
              type="submit"
              className="w-full text-left px-3 py-2 text-sm text-zinc-300 hover:bg-zinc-700"
            >
              Sign out
            </button>
          </form>
        </div>
      )}
    </div>
  )
}

const ChannelItem = React.forwardRef(({ item, isActive, onSelect, onClose }, ref) => {
  const hasUnread = item.unreadCount > 0 && !isActive

  return (
    <button
      ref={ref}
      onClick={() => onSelect(item.id)}
      className="w-full text-left px-4 py-1.5 flex items-center gap-2.5 text-[14px]"
      style={{
        backgroundColor: isActive ? '#252529' : 'transparent',
        borderLeft: isActive ? '5px solid #8b5cf6' : '5px solid transparent',
        color: isActive
          ? '#e4e4e7'
          : item.isMuted
            ? '#27272a'
            : hasUnread
              ? '#a1a1aa'
              : '#3f3f46',
        fontWeight: isActive ? 600 : hasUnread ? 500 : 400,
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

        {/* Unread indicator - deep infra red, not alert red */}
        {hasUnread && !item.isMuted && !isActive && (
          <span className="w-1.5 h-1.5 rounded-full" style={{ backgroundColor: '#991b1b' }} />
        )}
      </span>
    </button>
  )
})

const ChannelList = ({ channels, activeChannelId, onSelect, onClose }) => {
  const listRef = useRef(null)
  const activeItemRef = useRef(null)
  const hasScrolledRef = useRef(false)

  // Sort channels: unmuted first, then by name
  const sortedChannels = [...channels].sort((a, b) => {
    if (a.isMuted !== b.isMuted) return a.isMuted ? 1 : -1
    return a.name.localeCompare(b.name)
  })

  // Scroll active channel to center on initial load only, with slight offset for visual hint
  useLayoutEffect(() => {
    if (hasScrolledRef.current || !activeItemRef.current || !listRef.current) return

    // Use rAF to ensure layout is complete before measuring
    const frameId = requestAnimationFrame(() => {
      const container = listRef.current
      const item = activeItemRef.current
      if (!container || !item) return

      const itemTop = item.offsetTop
      const itemHeight = item.offsetHeight
      const containerHeight = container.clientHeight
      // Position item in center, then offset by ~half an item height to show partial cutoff
      const scrollPosition = itemTop - (containerHeight / 2) + (itemHeight / 2) - 3
      container.scrollTop = Math.max(0, scrollPosition)
      hasScrolledRef.current = true
    })

    return () => cancelAnimationFrame(frameId)
  }, [activeChannelId])

  return (
    <div ref={listRef} className="flex-1 overflow-y-auto pb-2 [&::-webkit-scrollbar]:hidden [-ms-overflow-style:none] [scrollbar-width:none]">
      {sortedChannels.map((channel) => (
        <ChannelItem
          key={channel.id}
          item={channel}
          isActive={activeChannelId === channel.id}
          onSelect={onSelect}
          onClose={onClose}
          ref={activeChannelId === channel.id ? activeItemRef : null}
        />
      ))}
    </div>
  )
}


const ChannelSwitcher = ({
  channels,
  activeChannelId,
  onChannelSelect,
  currentUser,
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
    <div className="flex flex-col overflow-hidden text-sm h-full w-full relative" style={{ backgroundColor: '#09090b' }}>

      {/* Full-width header - system rail */}
      <div className="flex-shrink-0 flex items-center justify-between px-4 py-1" style={{ backgroundColor: '#09090b' }}>
        <div className="flex items-center gap-2">
          {/* Mobile: tappable header that toggles sidebar */}
          <button
            onClick={() => setSidebarOpen(!sidebarOpen)}
            className="flex items-center gap-1.5 md:hidden"
          >
            <span className="text-[13px] font-medium tracking-tight" style={{ color: '#a1a1aa' }}>Invariant</span>
            <span className="text-[13px] font-light" style={{ color: '#27272a' }}>/</span>
            <span className="text-[13px]" style={{ color: '#3f3f46' }}>{activeChannelName}</span>
            <svg
              className="w-3 h-3"
              style={{ color: '#27272a', transform: sidebarOpen ? 'rotate(180deg)' : 'none' }}
              fill="none"
              stroke="currentColor"
              strokeWidth={2}
              viewBox="0 0 24 24"
            >
              <path strokeLinecap="round" strokeLinejoin="round" d="M19 9l-7 7-7-7" />
            </svg>
          </button>
          {/* Desktop: wordmark + tagline */}
          <div className="hidden md:flex md:items-center gap-3">
            <a href="/" className="text-[13px] font-medium tracking-tight hover:opacity-70 transition-opacity" style={{ color: '#a1a1aa' }}>
              Invariant
            </a>
            {/* Tagline */}
            <span className="text-[11px] tracking-[0.01em] hidden md:inline" style={{ color: '#27272a' }}>
              Sharpen how you think about distributed systems.
            </span>
          </div>
        </div>
        <div className="flex items-center gap-4">
          {/* Navigation links */}
          <nav className="hidden md:flex items-center gap-3 text-[11px]">
            <a href="/security" className="transition-colors" style={{ color: '#27272a' }} onMouseEnter={(e) => e.target.style.color = '#52525b'} onMouseLeave={(e) => e.target.style.color = '#27272a'}>Security</a>
            <a href="/privacy" className="transition-colors" style={{ color: '#27272a' }} onMouseEnter={(e) => e.target.style.color = '#52525b'} onMouseLeave={(e) => e.target.style.color = '#27272a'}>Privacy</a>
            <a href="/terms" className="transition-colors" style={{ color: '#27272a' }} onMouseEnter={(e) => e.target.style.color = '#52525b'} onMouseLeave={(e) => e.target.style.color = '#27272a'}>Terms</a>
          </nav>


          {/* User menu - show profile when logged in, sign-in button when not */}
          {currentUser ? (
            <UserMenu user={currentUser} />
          ) : (
            <form action="/auth/google_oauth2" method="post">
              <input type="hidden" name="authenticity_token" value={document.querySelector('meta[name="csrf-token"]')?.content || ''} />
              <button
                type="submit"
                className="inline-flex items-center gap-1.5 px-2 py-1 text-[11px] tracking-wide text-zinc-400 hover:text-zinc-300 transition-colors"
              >
                <svg className="w-3 h-3 opacity-70" viewBox="0 0 24 24">
                  <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
                  <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
                  <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/>
                  <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
                </svg>
                <span>Sign in</span>
              </button>
            </form>
          )}
        </div>
      </div>

      {/* Main layout with sidebar and content */}
      <div className="flex flex-1 min-h-0 overflow-hidden">

        {/* Channel sidebar - always visible on desktop */}
        <div
          className="hidden md:flex md:w-64 flex-shrink-0 flex-col"
          style={{ backgroundColor: '#131316', borderRight: '1px solid #27272a' }}
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
          <div className="flex-1 flex flex-col md:hidden" style={{ backgroundColor: '#131316' }}>
            <ChannelList
              channels={visibleChannels}
              activeChannelId={activeChannelId}
              onSelect={handleChannelSelect}
              onClose={null}
            />
            {/* Footer with tagline and links */}
            <div className="flex-shrink-0 border-t px-4 py-3 flex flex-col items-center gap-2" style={{ borderColor: '#232326' }}>
              <span className="text-[12px] tracking-[0.01em]" style={{ color: '#52525b' }}>
                Sharpen how you think about distributed systems.
              </span>
              <div className="flex items-center text-[13px]" style={{ color: '#71717a' }}>
                <a href="/privacy" className="hover:text-zinc-300 transition-colors">Privacy</a>
                <span className="mx-2" style={{ color: '#3f3f46' }}>·</span>
                <a href="/terms" className="hover:text-zinc-300 transition-colors">Terms</a>
                <span className="mx-2" style={{ color: '#3f3f46' }}>·</span>
                <a href="/security" className="hover:text-zinc-300 transition-colors">Security</a>
              </div>
            </div>
          </div>
        ) : (
          <div className="flex-1 flex flex-col min-w-0 min-h-0 md:hidden overflow-hidden" style={{ backgroundColor: '#18181b' }}>
            {children}
          </div>
        )}

        {/* Desktop: always show content */}
        <div className="hidden md:flex flex-1 flex-col min-w-0 min-h-0" style={{ backgroundColor: '#18181b' }}>
          {children}
        </div>
      </div>
    </div>
  )
}

export default ChannelSwitcher