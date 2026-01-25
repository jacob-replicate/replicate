import React from 'react'

// Table row wrapper with hover and border
export const TableRow = ({ children, href, onClick, isFirst = false, className = '' }) => {
  const borderClass = !isFirst ? 'border-t border-zinc-100 dark:border-zinc-700' : ''
  const hoverClass = 'hover:bg-zinc-50 dark:hover:bg-zinc-700/50'

  if (href) {
    return (
      <div className={borderClass}>
        <a href={href} className={`flex items-center px-4 py-2.5 ${hoverClass} ${className}`}>
          {children}
        </a>
      </div>
    )
  }

  if (onClick) {
    return (
      <div className={borderClass}>
        <button
          type="button"
          onClick={onClick}
          className={`w-full text-left flex items-center px-4 py-2.5 ${hoverClass} cursor-pointer ${className}`}
        >
          {children}
        </button>
      </div>
    )
  }

  return (
    <div className={`${borderClass} ${hoverClass} transition-colors ${className}`}>
      <div className="px-4 py-3">
        <div className="flex items-center justify-between gap-3">
          {children}
        </div>
      </div>
    </div>
  )
}

// Table row content (title + description)
export const TableRowContent = ({ title, description, titleClassName = '' }) => (
  <div className="flex-1 min-w-0">
    <div className={`text-[14px] ${titleClassName}`}>{title}</div>
    {description && (
      <div className="text-[13px] text-zinc-400 dark:text-zinc-500 mt-0.5">{description}</div>
    )}
  </div>
)

// Table row actions container
export const TableRowActions = ({ children }) => (
  <div className="flex items-center gap-2">
    {children}
  </div>
)

export const linkStyles = {
  unvisited: 'text-blue-600 dark:text-blue-400',
  visited: 'text-purple-600 dark:text-purple-400',
  muted: 'text-zinc-500 dark:text-zinc-400',
  default: 'text-zinc-600 dark:text-zinc-300',
}