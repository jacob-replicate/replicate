import React from 'react'

/**
 * ChannelItem - Single channel row in the sidebar
 */
const ChannelItem = React.forwardRef(({ item, isActive, onSelect, onClose }, ref) => {
  const lastMessageId = item.messages?.[item.messages.length - 1]?.id
  const hasUnread = lastMessageId && item.lastReadMessageId !== lastMessageId && !isActive

  return (
    <button
      ref={ref}
      onClick={() => onSelect(item.id)}
      className="w-full text-left px-4 py-1.5 flex items-center gap-2.5 text-[14px]"
      style={{
        backgroundColor: isActive ? '#1e1e24' : 'transparent',
        borderLeft: isActive ? '4px solid #7c6aab' : '4px solid transparent',
        boxShadow: isActive ? 'inset 0 1px 2px rgba(0,0,0,0.15)' : 'none',
        color: isActive
          ? '#f4f4f5'
          : item.isMuted
            ? '#27272a'
            : hasUnread
              ? '#d4d4d8'
              : '#52525b',
        fontWeight: isActive ? 600 : hasUnread ? 500 : 400,
      }}
      onMouseEnter={(e) => {
        if (!isActive) {
          e.currentTarget.style.backgroundColor = '#18181b'
          e.currentTarget.style.color = hasUnread ? '#ffffff' : '#a1a1aa'
        }
      }}
      onMouseLeave={(e) => {
        if (!isActive) {
          e.currentTarget.style.backgroundColor = 'transparent'
          e.currentTarget.style.color = hasUnread ? '#d4d4d8' : '#52525b'
        }
      }}
    >
      {item.isPrivate && (
        <svg className="w-3 h-3 flex-shrink-0 opacity-50" fill="currentColor" viewBox="0 0 16 16">
          <path d="M8 1a2 2 0 0 1 2 2v4H6V3a2 2 0 0 1 2-2zm3 6V3a3 3 0 0 0-6 0v4a2 2 0 0 0-2 2v5a2 2 0 0 0 2 2h6a2 2 0 0 0 2-2V9a2 2 0 0 0-2-2z"/>
        </svg>
      )}

      <span className="truncate flex-1">
        {item.name}
      </span>

      <span className="w-4 h-4 flex items-center justify-center flex-shrink-0">
        {hasUnread ? (
          <span
            className="w-2 h-2 rounded-full"
            style={{ backgroundColor: '#ef4444' }}
          />
        ) : null}
      </span>
    </button>
  )
})

ChannelItem.displayName = 'ChannelItem'

export default ChannelItem