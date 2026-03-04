import React, { useState, useRef, useEffect, forwardRef, useImperativeHandle } from 'react'

/**
 * MessageInput - chat input with optional topic dropdown
 */
export const MessageInput = forwardRef(({
  onSend,
  onChange,
  placeholder = 'Say something...',
  topics = null,
  currentTopic = null,
  onTopicChange = null,
  disabled = false,
  showHintIcon = false,
  onRequestHint = null,
  showNewButton = false,
  onRequestNew = null,
}, ref) => {
  const [value, setValue] = useState('')
  const [isDropdownOpen, setIsDropdownOpen] = useState(false)
  const inputRef = useRef(null)
  const dropdownRef = useRef(null)

  // Expose focus method to parent via ref
  useImperativeHandle(ref, () => ({
    focus: () => {
      inputRef.current?.focus({ preventScroll: true })
    }
  }), [])

  // Close dropdown when clicking outside
  useEffect(() => {
    const handleClickOutside = (e) => {
      if (dropdownRef.current && !dropdownRef.current.contains(e.target)) {
        setIsDropdownOpen(false)
      }
    }
    document.addEventListener('mousedown', handleClickOutside)
    return () => document.removeEventListener('mousedown', handleClickOutside)
  }, [])

  // Notify parent of value changes
  const handleChange = (e) => {
    const newValue = e.target.value
    setValue(newValue)
    onChange?.(newValue)
  }

  const handleSubmit = (e) => {
    e.preventDefault()
    if (!value.trim() || disabled) return
    onSend?.(value.trim())
    setValue('')
    onChange?.('')
  }

  const handleKeyDown = (e) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault()
      handleSubmit(e)
    }
  }

  return (
    <form
      onSubmit={handleSubmit}
      className="flex items-center"
      style={{ backgroundColor: '#18181a', borderTop: '1px solid #27272a' }}
    >
      <div className="relative flex-1">
        <input
          ref={inputRef}
          type="text"
          value={value}
          onChange={handleChange}
          onKeyDown={handleKeyDown}
          placeholder={placeholder}
          disabled={disabled}
          className={`w-full px-4 py-3 text-[15px] outline-none border-none bg-transparent ring-0 focus:ring-0 focus:outline-none disabled:opacity-50 placeholder-[#52525b] ${(onRequestHint || onRequestNew) ? 'pr-36' : ''}`}
          style={{ color: '#f4f4f5', caretColor: '#d4d4d8' }}
        />

        {/* Action buttons - terminal/engineer aesthetic */}
        <div className="absolute right-2 top-1/2 -translate-y-1/2 flex items-center gap-2">
          {onRequestNew && (
            <button
              type="button"
              onClick={onRequestNew}
              className="px-3 py-1 rounded-md"
              title="Start a new scenario"
              style={{
                backgroundColor: '#252528',
                color: '#4ade80',
                boxShadow: '0 1px 3px rgba(0,0,0,0.4), 0 0 0 1px rgba(255,255,255,0.05)',
              }}
              onMouseEnter={(e) => {
                e.currentTarget.style.backgroundColor = '#2d2d30'
                e.currentTarget.style.color = '#86efac'
                e.currentTarget.style.boxShadow = '0 2px 6px rgba(0,0,0,0.5), 0 0 0 1px rgba(255,255,255,0.08)'
              }}
              onMouseLeave={(e) => {
                e.currentTarget.style.backgroundColor = '#252528'
                e.currentTarget.style.color = '#4ade80'
                e.currentTarget.style.boxShadow = '0 1px 3px rgba(0,0,0,0.4), 0 0 0 1px rgba(255,255,255,0.05)'
              }}
            >
              <span className="text-sm font-mono">/new</span>
            </button>
          )}

          {onRequestHint && (
            <button
              type="button"
              onClick={onRequestHint}
              className="px-3 py-1 rounded-md"
              title="Need a nudge? Click for options"
              style={{
                backgroundColor: '#252528',
                color: '#4ade80',
                boxShadow: '0 1px 3px rgba(0,0,0,0.4), 0 0 0 1px rgba(255,255,255,0.05)',
              }}
              onMouseEnter={(e) => {
                e.currentTarget.style.backgroundColor = '#2d2d30'
                e.currentTarget.style.color = '#86efac'
                e.currentTarget.style.boxShadow = '0 2px 6px rgba(0,0,0,0.5), 0 0 0 1px rgba(255,255,255,0.08)'
              }}
              onMouseLeave={(e) => {
                e.currentTarget.style.backgroundColor = '#252528'
                e.currentTarget.style.color = '#4ade80'
                e.currentTarget.style.boxShadow = '0 1px 3px rgba(0,0,0,0.4), 0 0 0 1px rgba(255,255,255,0.05)'
              }}
            >
              <span className="text-sm font-mono">/hint</span>
            </button>
          )}
        </div>
      </div>

      {/* Topic dropdown */}
      {topics && topics.length > 0 && (
        <div ref={dropdownRef} className="relative mr-2">
          <button
            type="button"
            onClick={() => setIsDropdownOpen(!isDropdownOpen)}
            className="flex items-center gap-1.5 px-3 py-1.5 text-[13px] font-medium border-2 rounded-md transition-colors"
            style={{
              borderColor: '#1a365d',
              color: '#1a365d',
            }}
          >
            <span>{currentTopic?.name || 'Select topic'}</span>
            <svg
              className={`w-3.5 h-3.5 transition-transform ${isDropdownOpen ? 'rotate-180' : ''}`}
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
            </svg>
          </button>

          {isDropdownOpen && (
            <div className="absolute bottom-full mb-1 right-0 w-48 bg-white dark:bg-zinc-800 rounded-lg shadow-lg border border-zinc-200 dark:border-zinc-700 py-1 z-50">
              {topics.map((topic) => (
                <button
                  key={topic.code || topic.name}
                  type="button"
                  onClick={() => {
                    onTopicChange?.(topic)
                    setIsDropdownOpen(false)
                  }}
                  className={`w-full text-left px-3 py-2 text-[13px] transition-colors ${
                    currentTopic?.code === topic.code
                      ? 'bg-zinc-100 dark:bg-zinc-700 font-medium text-zinc-900 dark:text-white'
                      : 'text-zinc-600 dark:text-zinc-300 hover:bg-zinc-50 dark:hover:bg-zinc-700/50'
                  }`}
                >
                  {topic.name}
                </button>
              ))}
            </div>
          )}
        </div>
      )}
    </form>
  )
})

MessageInput.displayName = 'MessageInput'

export default MessageInput