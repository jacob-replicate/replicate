import React, { useState, useRef, useEffect } from 'react'

/**
 * MessageInput - chat input with optional topic dropdown
 */
export const MessageInput = ({
  onSend,
  placeholder = 'Say something...',
  topics = null,
  currentTopic = null,
  onTopicChange = null,
  disabled = false,
}) => {
  const [value, setValue] = useState('')
  const [isDropdownOpen, setIsDropdownOpen] = useState(false)
  const inputRef = useRef(null)
  const dropdownRef = useRef(null)

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

  const handleSubmit = (e) => {
    e.preventDefault()
    if (!value.trim() || disabled) return
    onSend?.(value.trim())
    setValue('')
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
      className="border-t border-zinc-200 dark:border-zinc-700 flex items-center bg-white dark:bg-zinc-900"
    >
      <input
        ref={inputRef}
        type="text"
        value={value}
        onChange={(e) => setValue(e.target.value)}
        onKeyDown={handleKeyDown}
        placeholder={placeholder}
        disabled={disabled}
        className="flex-1 px-4 py-3 text-[15px] text-zinc-800 dark:text-zinc-200 placeholder-zinc-400 dark:placeholder-zinc-500 outline-none border-none bg-transparent ring-0 focus:ring-0 focus:outline-none disabled:opacity-50"
      />

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
}

export default MessageInput