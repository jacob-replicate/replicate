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
  const [copied, setCopied] = useState(false)
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
        className="flex-shrink-0 flex items-center justify-between px-5 py-2.5"
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
          <div className="hidden md:flex md:items-baseline gap-4">
            <a href="/" className="text-[15px] hover:opacity-70 transition-opacity" style={{ color: '#ffffff', fontWeight: 600 }}>
              Invariant
            </a>
            {/* Tagline */}
            <span className="text-[13px]" style={{ color: '#9a9a9a', fontWeight: 400 }}>
              Sharpen how you think about distributed systems.
            </span>
          </div>
        </div>
        <div className="flex items-center gap-6">
          {/* Navigation links */}
          <nav className="hidden md:flex items-center gap-4 text-[12px]" style={{ fontWeight: 400 }}>
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
                className="inline-flex items-center gap-1.5 text-[12px]"
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

          {/* Sharing buttons */}
          <div className="mt-auto px-4 py-3 flex items-center justify-center gap-3" style={{ borderTop: '1px solid #27272a' }}>
            <a
              href="https://twitter.com/intent/tweet?text=Sharpen%20how%20you%20think%20about%20distributed%20systems&url=https://invariant.training"
              target="_blank"
              rel="noopener noreferrer"
              className="p-1.5 rounded hover:bg-zinc-800"
              style={{ color: '#52525b' }}
              onMouseEnter={(e) => e.currentTarget.style.color = '#a1a1aa'}
              onMouseLeave={(e) => e.currentTarget.style.color = '#52525b'}
              title="Share on X"
            >
              <svg className="w-4 h-4" viewBox="0 0 24 24" fill="currentColor">
                <path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z"/>
              </svg>
            </a>
            <a
              href="https://www.linkedin.com/sharing/share-offsite/?url=https://invariant.training"
              target="_blank"
              rel="noopener noreferrer"
              className="p-1.5 rounded hover:bg-zinc-800"
              style={{ color: '#52525b' }}
              onMouseEnter={(e) => e.currentTarget.style.color = '#a1a1aa'}
              onMouseLeave={(e) => e.currentTarget.style.color = '#52525b'}
              title="Share on LinkedIn"
            >
              <svg className="w-4 h-4" viewBox="0 0 24 24" fill="currentColor">
                <path d="M20.447 20.452h-3.554v-5.569c0-1.328-.027-3.037-1.852-3.037-1.853 0-2.136 1.445-2.136 2.939v5.667H9.351V9h3.414v1.561h.046c.477-.9 1.637-1.85 3.37-1.85 3.601 0 4.267 2.37 4.267 5.455v6.286zM5.337 7.433c-1.144 0-2.063-.926-2.063-2.065 0-1.138.92-2.063 2.063-2.063 1.14 0 2.064.925 2.064 2.063 0 1.139-.925 2.065-2.064 2.065zm1.782 13.019H3.555V9h3.564v11.452zM22.225 0H1.771C.792 0 0 .774 0 1.729v20.542C0 23.227.792 24 1.771 24h20.451C23.2 24 24 23.227 24 22.271V1.729C24 .774 23.2 0 22.222 0h.003z"/>
              </svg>
            </a>
            <a
              href="https://www.facebook.com/sharer/sharer.php?u=https://invariant.training"
              target="_blank"
              rel="noopener noreferrer"
              className="p-1.5 rounded hover:bg-zinc-800"
              style={{ color: '#52525b' }}
              onMouseEnter={(e) => e.currentTarget.style.color = '#a1a1aa'}
              onMouseLeave={(e) => e.currentTarget.style.color = '#52525b'}
              title="Share on Facebook"
            >
              <svg className="w-4 h-4" viewBox="0 0 24 24" fill="currentColor">
                <path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z"/>
              </svg>
            </a>
            <a
              href="mailto:?subject=Invariant%20-%20Distributed%20Systems%20Training&body=Sharpen%20how%20you%20think%20about%20distributed%20systems%3A%20https://invariant.training"
              className="p-1.5 rounded hover:bg-zinc-800"
              style={{ color: '#52525b' }}
              onMouseEnter={(e) => e.currentTarget.style.color = '#a1a1aa'}
              onMouseLeave={(e) => e.currentTarget.style.color = '#52525b'}
              title="Share via email"
            >
              <svg className="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <rect x="2" y="4" width="20" height="16" rx="2"/>
                <path d="m22 7-8.97 5.7a1.94 1.94 0 0 1-2.06 0L2 7"/>
              </svg>
            </a>
            <button
              onClick={() => {
                navigator.clipboard.writeText('https://invariant.training')
                setCopied(true)
                setTimeout(() => setCopied(false), 2000)
              }}
              className="p-1.5 rounded hover:bg-zinc-800"
              style={{ color: copied ? '#4ade80' : '#52525b' }}
              onMouseEnter={(e) => { if (!copied) e.currentTarget.style.color = '#a1a1aa' }}
              onMouseLeave={(e) => { if (!copied) e.currentTarget.style.color = '#52525b' }}
              title={copied ? 'Copied!' : 'Copy link'}
            >
              {copied ? (
                <svg className="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                  <polyline points="20 6 9 17 4 12" />
                </svg>
              ) : (
                <svg className="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                  <path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71" />
                  <path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71" />
                </svg>
              )}
            </button>
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
              <span className="text-[12px] tracking-[0.01em]" style={{ color: '#a1a1aa' }}>
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