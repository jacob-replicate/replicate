import React from 'react'
import { Link, useLocation } from 'react-router-dom'

// Topics (these could come from props/API, but 6 is the fixed set)
const DEFAULT_TOPICS = [
  { name: 'compute', code: 'compute' },
  { name: 'delivery', code: 'delivery' },
  { name: 'governance', code: 'governance' },
  { name: 'networking', code: 'networking' },
  { name: 'observability', code: 'observability' },
  { name: 'storage', code: 'storage' },
]

/**
 * TopicNav - horizontal topic navigation bar
 */
export const TopicNav = ({ topics = DEFAULT_TOPICS, currentTopic, onTopicSelect }) => {
  const location = useLocation()

  // Determine active topic from URL or prop
  const activeTopic = currentTopic || location.pathname.split('/').filter(Boolean)[0]

  // Hidden - kept in code but never shown
  if (true) return null

  return (
    <div className="bg-zinc-100/80 dark:bg-zinc-800 rounded-xl shadow-sm border border-zinc-200/60 dark:border-zinc-700 overflow-hidden mb-4">
      <div className="flex flex-wrap md:flex-nowrap">
        {topics.map(topic => {
          const isActive = activeTopic === topic.code
          return (
            <Link
              key={topic.code}
              to={`/${topic.code}`}
              onClick={() => onTopicSelect?.(topic)}
              className={`w-1/3 md:w-auto md:flex-1 text-center py-3 px-2 md:px-4 text-[12px] md:text-[13px] tracking-wide cursor-pointer transition-all duration-150 ${
                isActive
                  ? 'text-white font-medium scale-105'
                  : 'text-zinc-400 hover:text-zinc-500 hover:scale-105 font-light'
              }`}
              style={isActive ? { backgroundColor: '#1a365d' } : {}}
            >
              {topic.name}
            </Link>
          )
        })}
      </div>
    </div>
  )
}

export default TopicNav