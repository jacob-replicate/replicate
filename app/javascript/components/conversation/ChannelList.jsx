import React, { useRef, useLayoutEffect } from 'react'
import ChannelItem from './ChannelItem'

/**
 * ChannelList - Scrollable list of channels in sidebar
 */
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

export default ChannelList