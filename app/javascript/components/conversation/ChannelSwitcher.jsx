import React, { useState } from 'react'
import ChannelList from './ChannelList'

/**
 * ChannelSwitcher - Main layout with sidebar and content area
 */

const ChannelSwitcher = ({
  channels,
  activeChannelId,
  onChannelSelect,
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
            className="flex items-center gap-1.5 lg:hidden"
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
          <div className="hidden lg:flex lg:items-baseline gap-4">
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
          <nav className="hidden lg:flex items-center gap-4 text-[12px]" style={{ fontWeight: 400 }}>
            <a href="/security" style={{ color: '#71717a' }} onMouseEnter={(e) => e.target.style.color = '#a1a1aa'} onMouseLeave={(e) => e.target.style.color = '#71717a'}>Security</a>
            <a href="/privacy" style={{ color: '#71717a' }} onMouseEnter={(e) => e.target.style.color = '#a1a1aa'} onMouseLeave={(e) => e.target.style.color = '#71717a'}>Privacy</a>
            <a href="/terms" style={{ color: '#71717a' }} onMouseEnter={(e) => e.target.style.color = '#a1a1aa'} onMouseLeave={(e) => e.target.style.color = '#71717a'}>Terms</a>
          </nav>

          {/* Mobile: share button - far right */}
          <button
            onClick={() => {
              if (navigator.share) {
                navigator.share({
                  title: 'Invariant',
                  text: 'Sharpen how you think about distributed systems.',
                  url: 'https://invariant.training',
                })
              } else {
                navigator.clipboard.writeText('https://invariant.training')
                setCopied(true)
                setTimeout(() => setCopied(false), 2000)
              }
            }}
            className="p-1.5 rounded lg:hidden"
            style={{ color: copied ? '#4ade80' : '#71717a' }}
            title={copied ? 'Copied!' : 'Share'}
          >
            {copied ? (
              <svg className="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <polyline points="20 6 9 17 4 12" />
              </svg>
            ) : (
              <svg className="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <path d="M4 12v8a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2v-8" />
                <polyline points="16 6 12 2 8 6" />
                <line x1="12" y1="2" x2="12" y2="15" />
              </svg>
            )}
          </button>
        </div>
      </div>

      {/* Main layout with sidebar and content */}
      <div className="flex flex-1 min-h-0 overflow-hidden">

        {/* Channel sidebar - always visible on desktop */}
        <div
          className="hidden lg:flex lg:w-64 flex-shrink-0 flex-col pt-2"
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
          <div className="mt-auto px-4 py-4 flex items-center justify-center gap-3">
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
              <svg className="w-[18px] h-[18px]" viewBox="0 0 24 24" fill="currentColor">
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
              <svg className="w-[18px] h-[18px]" viewBox="0 0 24 24" fill="currentColor">
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
              <svg className="w-[18px] h-[18px]" viewBox="0 0 24 24" fill="currentColor">
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
              <svg className="w-[18px] h-[18px]" viewBox="0 0 24 24" fill="currentColor">
                <path d="M1.5 8.67v8.58a3 3 0 003 3h15a3 3 0 003-3V8.67l-8.928 5.493a3 3 0 01-3.144 0L1.5 8.67z"/>
                <path d="M22.5 6.908V6.75a3 3 0 00-3-3h-15a3 3 0 00-3 3v.158l9.714 5.978a1.5 1.5 0 001.572 0L22.5 6.908z"/>
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
                <svg className="w-[18px] h-[18px]" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                  <polyline points="20 6 9 17 4 12" />
                </svg>
              ) : (
                <svg className="w-[18px] h-[18px]" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                  <path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71" />
                  <path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71" />
                </svg>
              )}
            </button>
          </div>
        </div>

        {/* Mobile: show either channel list OR content */}
        {sidebarOpen ? (
          <div className="flex-1 flex flex-col lg:hidden" style={{ backgroundColor: '#131315' }}>
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
            className="flex-1 flex flex-col min-w-0 min-h-0 lg:hidden overflow-hidden"
            style={{
              background: 'linear-gradient(180deg, #19191c 0%, #141416 100%)',
            }}
          >
            {children}
          </div>
        )}

        {/* Desktop: always show content */}
        <div
          className="hidden lg:flex flex-1 flex-col min-w-0 min-h-0"
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