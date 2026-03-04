import React, { useState } from 'react'
import UserMenu from './UserMenu'
import ChannelList from './ChannelList'

/**
 * ChannelSwitcher - Main layout with sidebar and content area
 */

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
      <div
        className="flex-shrink-0 flex items-center justify-between px-5 py-1.5"
        style={{
          background: 'linear-gradient(180deg, #141416 0%, #0c0c0e 100%)',
          borderBottom: '1px solid #27272a',
        }}
      >
        <div className="flex items-center gap-2">
          {/* Mobile: tappable header that toggles sidebar */}
          <button
            onClick={() => setSidebarOpen(!sidebarOpen)}
            className="flex items-center gap-1.5 md:hidden"
          >
            <span className="text-[14px]" style={{ color: '#ffffff', fontWeight: 600 }}>Invariant</span>
            <span className="text-[14px]" style={{ color: '#52525b', fontWeight: 600 }}>/</span>
            <span className="text-[14px]" style={{ color: '#9d8ec4' }}>{activeChannelName}</span>
            <svg
              className="w-3 h-3"
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
          <div className="hidden md:flex md:items-baseline gap-[10px]">
            <a href="/" className="text-[15px] hover:opacity-70 transition-opacity" style={{ color: '#ffffff', fontWeight: 600 }}>
              Invariant
            </a>
            <span className="text-[15px]" style={{ color: '#52525b', fontWeight: 600 }}>/</span>
            {/* Tagline */}
            <span className="text-[13px]" style={{ color: '#9d8ec4', fontWeight: 400 }}>
              Sharpen how you think about distributed systems.
            </span>
          </div>
        </div>
        <div className="flex items-center gap-6">
          {/* Navigation links */}
          <nav className="hidden md:flex items-center gap-4 text-[13px] tracking-tight" style={{ fontWeight: 400 }}>
            <a href="/security" style={{ color: '#71717a' }} onMouseEnter={(e) => e.target.style.color = '#a1a1aa'} onMouseLeave={(e) => e.target.style.color = '#71717a'}>Security</a>
            <a href="/privacy" style={{ color: '#71717a' }} onMouseEnter={(e) => e.target.style.color = '#a1a1aa'} onMouseLeave={(e) => e.target.style.color = '#71717a'}>Privacy</a>
            <a href="/terms" style={{ color: '#71717a' }} onMouseEnter={(e) => e.target.style.color = '#a1a1aa'} onMouseLeave={(e) => e.target.style.color = '#71717a'}>Terms</a>
          </nav>

          {/* User menu - show profile when logged in, sign-in button when not */}
          {currentUser ? (
            <UserMenu user={currentUser} />
          ) : (
            <form action="/auth/google_oauth2" method="post" className="flex items-center">
              <input type="hidden" name="authenticity_token" value={document.querySelector('meta[name="csrf-token"]')?.content || ''} />
              <button
                type="submit"
                className="inline-flex items-center gap-1.5 text-[13px]"
                style={{ color: '#71717a', fontWeight: 400 }}
                onMouseEnter={(e) => e.target.style.color = '#a1a1aa'}
                onMouseLeave={(e) => e.target.style.color = '#71717a'}
              >
                <svg className="w-3.5 h-3.5" viewBox="0 0 24 24">
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
          className="hidden md:flex md:w-64 flex-shrink-0 flex-col pt-2"
          style={{ backgroundColor: '#131315', borderRight: '1px solid #27272a' }}
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

          {/* Command legend */}
          <div className="mt-auto px-4 py-3 space-y-1">
            <div className="flex items-center gap-2 text-[12px]">
              <span className="font-mono w-24" style={{ color: '#a39e6e' }}>/h /hint</span>
              <span style={{ color: '#71717a' }}>get a nudge</span>
            </div>
            <div className="flex items-center gap-2 text-[12px]">
              <span className="font-mono w-24" style={{ color: '#a39e6e' }}>/n /new</span>
              <span style={{ color: '#71717a' }}>new scenario</span>
            </div>
          </div>
        </div>

        {/* Mobile: show either channel list OR content */}
        {sidebarOpen ? (
          <div className="flex-1 flex flex-col md:hidden" style={{ backgroundColor: '#131315' }}>
            <ChannelList
              channels={visibleChannels}
              activeChannelId={activeChannelId}
              onSelect={handleChannelSelect}
              onClose={null}
            />
            {/* Footer with tagline and links */}
            <div className="flex-shrink-0 border-t px-4 py-3 flex flex-col items-center gap-2" style={{ borderColor: '#232326' }}>
              <span className="text-[12px] tracking-[0.01em]" style={{ color: '#9d8ec4' }}>
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
          <div
            className="flex-1 flex flex-col min-w-0 min-h-0 md:hidden overflow-hidden"
            style={{
              background: 'linear-gradient(180deg, #19191c 0%, #141416 100%)',
            }}
          >
            {children}
          </div>
        )}

        {/* Desktop: always show content */}
        <div
          className="hidden md:flex flex-1 flex-col min-w-0 min-h-0"
          style={{
            background: 'linear-gradient(180deg, #19191c 0%, #141416 100%)',
          }}
        >
          {children}
        </div>
      </div>
    </div>
  )
}

export default ChannelSwitcher