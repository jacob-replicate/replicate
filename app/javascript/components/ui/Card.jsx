import React from 'react'

// Card container with header
export const Card = ({ children, className = '' }) => (
  <section className={`bg-white dark:bg-zinc-800 rounded-md shadow-xs overflow-hidden border-2 border-zinc-300 dark:border-zinc-700 ${className}`}>
    {children}
  </section>
)

// Card header with title, description, and optional counter
export const CardHeader = ({ title, description, counter, counterComplete }) => {
  const counterColor = counterComplete
    ? 'text-emerald-600 dark:text-emerald-400'
    : 'text-zinc-400 dark:text-zinc-500'

  return (
    <div className="px-4 pt-4 pb-3">
      <div className="flex items-center justify-between gap-3">
        <div>
          <h2 className="text-[15px] font-semibold text-zinc-800 dark:text-zinc-100">{title}</h2>
          {description && (
            <p className="text-[13px] text-zinc-500 dark:text-zinc-400 mt-0.5">{description}</p>
          )}
        </div>
        {counter && (
          <span className={`text-[11px] tabular-nums flex-shrink-0 ${counterColor}`}>
            {counter}
          </span>
        )}
      </div>
    </div>
  )
}

// Card body for list items
export const CardBody = ({ children }) => (
  <div className="border-t border-zinc-100 dark:border-zinc-700">
    {children}
  </div>
)

// Card footer (for empty states, loading, etc.)
export const CardFooter = ({ children, centered = false }) => (
  <div className="border-t border-zinc-100 dark:border-zinc-700">
    <div className={`px-4 py-3 ${centered ? 'flex items-center justify-center gap-2' : 'flex items-center justify-between'}`}>
      {children}
    </div>
  </div>
)