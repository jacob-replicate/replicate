import React, { createContext, useContext, useState, useCallback } from 'react'

const NotificationContext = createContext(null)

/**
 * Hook to access notification API
 * @returns {{ showNotification: Function, dismissNotification: Function, notifications: Array }}
 */
export const useNotifications = () => {
  const context = useContext(NotificationContext)
  if (!context) {
    throw new Error('useNotifications must be used within NotificationProvider')
  }
  return context
}

let notificationId = 0

/**
 * NotificationProvider - manages toast notifications
 *
 * Usage:
 *   const { showNotification } = useNotifications()
 *   showNotification({
 *     avatar: '/profile-photo-1.jpg',
 *     title: 'alex',
 *     message: 'just deployed the fix to prod',
 *     channelId: 'dns',  // optional - clicking opens this channel
 *   })
 */
export function NotificationProvider({ children, onNotificationClick }) {
  const [notifications, setNotifications] = useState([])

  const showNotification = useCallback(({ avatar, title, message, channelId, channelName }) => {
    const id = ++notificationId
    setNotifications(prev => [...prev, { id, avatar, title, message, channelId, channelName }])
    return id
  }, [])

  const dismissNotification = useCallback((id) => {
    setNotifications(prev => prev.filter(n => n.id !== id))
  }, [])

  const handleClick = useCallback((notification) => {
    if (notification.channelId && onNotificationClick) {
      onNotificationClick(notification.channelId)
    }
    dismissNotification(notification.id)
  }, [onNotificationClick, dismissNotification])

  return (
    <NotificationContext.Provider value={{ showNotification, dismissNotification, notifications }}>
      {children}
      <NotificationStack
        notifications={notifications}
        onDismiss={dismissNotification}
        onClick={handleClick}
      />
    </NotificationContext.Provider>
  )
}

/**
 * NotificationStack - renders notifications
 * Desktop: top-right corner
 * Mobile: top of screen, full width
 */
function NotificationStack({ notifications, onDismiss, onClick }) {
  if (notifications.length === 0) return null

  return (
    <div className="fixed z-50 flex flex-col gap-2 pointer-events-none
      top-4 left-4 right-4
      sm:left-auto sm:right-4">
      {notifications.map(notification => (
        <NotificationToast
          key={notification.id}
          notification={notification}
          onDismiss={() => onDismiss(notification.id)}
          onClick={() => onClick(notification)}
        />
      ))}
    </div>
  )
}

/**
 * NotificationToast - single notification popup
 */
function NotificationToast({ notification, onDismiss, onClick }) {
  // Capitalize first letter of title (author name)
  const capitalizedTitle = notification.title
    ? notification.title.charAt(0).toUpperCase() + notification.title.slice(1)
    : ''

  return (
    <div
      className="pointer-events-auto flex items-start gap-3 p-3 pr-2 rounded-lg shadow-lg cursor-pointer w-full sm:min-w-[300px] sm:max-w-[400px] sm:w-auto"
      style={{
        backgroundColor: '#1e1e24',
        border: '1px solid #7c6aab',
      }}
      onClick={onClick}
    >
      {notification.avatar && (
        <img
          src={notification.avatar}
          alt=""
          className="w-10 h-10 rounded-full flex-shrink-0"
        />
      )}
      <div className="flex-1 min-w-0">
        <div className="text-sm font-medium text-zinc-200">
          {capitalizedTitle}
          {notification.channelName && (
            <>
              {' in '}
              <span className="text-purple-400">{notification.channelName}</span>
            </>
          )}
        </div>
        <div
          className="text-sm text-zinc-400"
          style={{
            display: '-webkit-box',
            WebkitLineClamp: 2,
            WebkitBoxOrient: 'vertical',
            overflow: 'hidden',
          }}
        >
          {notification.message}
        </div>
      </div>
      <button
        onClick={(e) => {
          e.stopPropagation()
          onDismiss()
        }}
        className="p-1 text-zinc-500 hover:text-zinc-300 flex-shrink-0"
      >
        <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
        </svg>
      </button>
    </div>
  )
}

export default NotificationProvider