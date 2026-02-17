import React, { useState, useRef } from 'react'

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
  serverName = 'invariant.training',
}) => {
  return (
    <div className="flex bg-zinc-800 overflow-hidden font-mono text-sm h-full w-full">

      {/* Channel sidebar */}
      <div className="w-56 flex-shrink-0 bg-zinc-800 border-r border-zinc-700 flex flex-col">
        {/* Server header */}
        <div className="px-3 py-2.5 border-b border-zinc-700">
          <div className="text-zinc-500 text-xs uppercase tracking-wider">Server</div>
          <div className="text-green-400 font-medium truncate">{serverName}</div>
        </div>

        {/* Channel list */}
        <div className="flex-1 overflow-y-auto py-2">
          <div className="px-3 py-1 text-zinc-500 text-xs uppercase tracking-wider">Channels</div>
          {channels.map((channel) => (
            <button
              key={channel.id}
              onClick={() => onChannelSelect(channel.id)}
              className={`w-full text-left px-3 py-1.5 flex items-center gap-2 hover:bg-zinc-700/50 ${
                activeChannelId === channel.id 
                  ? 'bg-zinc-700 text-white' 
                  : 'text-zinc-400'
              }`}
            >
              {/* Activity indicator */}
              {channel.isActive && (
                <span className="w-1.5 h-1.5 rounded-full bg-green-500 flex-shrink-0" />
              )}
              {!channel.isActive && channel.unreadCount > 0 && (
                <span className="w-1.5 h-1.5 rounded-full bg-amber-500 flex-shrink-0" />
              )}
              {!channel.isActive && channel.unreadCount === 0 && (
                <span className="w-1.5 h-1.5 flex-shrink-0" />
              )}

              <span className="truncate">#{channel.name}</span>

              {/* Unread count */}
              {channel.unreadCount > 0 && activeChannelId !== channel.id && (
                <span className="ml-auto text-xs bg-amber-500/20 text-amber-400 px-1.5 rounded">
                  {channel.unreadCount}
                </span>
              )}
            </button>
          ))}
        </div>

        {/* User info footer */}
        <div className="px-3 py-2 border-t border-zinc-700 text-zinc-500 text-xs">
          <span className="text-green-400">●</span> jacob
        </div>
      </div>

      {/* Main content area */}
      <div className="flex-1 flex flex-col min-w-0 bg-zinc-900">
        {children}
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