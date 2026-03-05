import React from 'react'

/**
 * Typing indicator with animated dots - uses color pulse, no y-position change
 */
export const TypingIndicator = ({ author }) => {
  const name = typeof author === 'object' ? author.name : author
  const avatar = typeof author === 'object' ? author.avatar : null

  return (
    <div className="flex items-start gap-3">
      {avatar ? (
        <img src={avatar} alt="" className="w-10 h-10 rounded-full flex-shrink-0 ring-1 ring-zinc-700/60" style={{ filter: 'brightness(0.9) saturate(0.9)' }} />
      ) : (
        <div className="w-10 h-10 rounded-full flex-shrink-0 bg-zinc-700" />
      )}
      <div className="flex-1">
        {name && (
          <div className="flex items-baseline gap-2 mb-1">
            <span className="font-semibold text-zinc-100 text-[15px] tracking-[-0.01em]">
              {name}
            </span>
          </div>
        )}
        <div className="flex items-center gap-1">
          <div className="flex gap-1">
            <div
              className="w-2 h-2 rounded-full animate-typing-pulse bg-zinc-500"
              style={{ animationDelay: '0ms' }}
            />
            <div
              className="w-2 h-2 rounded-full animate-typing-pulse bg-zinc-500"
              style={{ animationDelay: '200ms' }}
            />
            <div
              className="w-2 h-2 rounded-full animate-typing-pulse bg-zinc-500"
              style={{ animationDelay: '400ms' }}
            />
          </div>
        </div>
      </div>
    </div>
  )
}

export default TypingIndicator