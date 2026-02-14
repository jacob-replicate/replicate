import React, { useState, useEffect, useCallback } from 'react'
import conversationManager from '../../lib/ConversationManager'

/**
 * BackgroundNotification - Toast-style notification for background conversation updates
 */
const BackgroundNotification = ({ onNavigate }) => {
  const [notifications, setNotifications] = useState([])

  // Listen for background notifications
  useEffect(() => {
    const unsubscribe = conversationManager.onBackgroundNotification(({ conversationId, message }) => {
      const id = `${conversationId}-${Date.now()}`

      const notification = {
        id,
        conversationId,
        message,
        timestamp: new Date(),
      }

      setNotifications(prev => [...prev, notification])

      // Auto-dismiss after 8 seconds
      setTimeout(() => {
        setNotifications(prev => prev.filter(n => n.id !== id))
      }, 8000)
    })

    return unsubscribe
  }, [])

  const dismiss = useCallback((id) => {
    setNotifications(prev => prev.filter(n => n.id !== id))
  }, [])

  const handleClick = useCallback((notification) => {
    dismiss(notification.id)
    if (onNavigate) {
      onNavigate(notification.conversationId)
    }
  }, [dismiss, onNavigate])

  if (notifications.length === 0) return null

  return (
    <div className="fixed bottom-4 right-4 z-50 flex flex-col gap-2 max-w-sm">
      {notifications.map(notification => (
        <div
          key={notification.id}
          className="bg-white dark:bg-zinc-800 rounded-lg shadow-lg border border-zinc-200 dark:border-zinc-700 p-4 cursor-pointer hover:shadow-xl transition-shadow animate-slide-in"
          onClick={() => handleClick(notification)}
        >
          <div className="flex items-start gap-3">
            {/* Avatar */}
            {notification.message.author?.avatar ? (
              <img
                src={notification.message.author.avatar}
                alt={notification.message.author.name}
                className="w-8 h-8 rounded-full flex-shrink-0"
              />
            ) : (
              <div className="w-8 h-8 rounded-full bg-zinc-300 dark:bg-zinc-600 flex-shrink-0 flex items-center justify-center text-xs font-medium text-zinc-600 dark:text-zinc-300">
                {notification.message.author?.name?.[0]?.toUpperCase() || '?'}
              </div>
            )}

            <div className="flex-1 min-w-0">
              <div className="flex items-center gap-2">
                <span className="font-medium text-sm text-zinc-900 dark:text-zinc-100">
                  {notification.message.author?.name || 'Unknown'}
                </span>
                <span className="text-xs text-zinc-500 dark:text-zinc-400">
                  New update
                </span>
              </div>
              <p className="text-sm text-zinc-600 dark:text-zinc-300 truncate mt-0.5">
                {notification.message.content}
              </p>
            </div>

            {/* Close button */}
            <button
              onClick={(e) => {
                e.stopPropagation()
                dismiss(notification.id)
              }}
              className="text-zinc-400 hover:text-zinc-600 dark:hover:text-zinc-200 flex-shrink-0"
            >
              <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>
        </div>
      ))}
    </div>
  )
}

export default BackgroundNotification