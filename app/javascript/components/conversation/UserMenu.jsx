import React, { useState, useRef, useEffect } from 'react'

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

export default UserMenu