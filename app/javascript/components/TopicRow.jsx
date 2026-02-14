import React from 'react'
import { TableRow, TableRowContent, linkStyles } from './ui'

const TopicRow = ({ topic, index, onTopicClick }) => {
  const conversationCount = topic.conversation_count || 0
  const completedCount = topic.completed_count || 0
  const isDone = completedCount === conversationCount && conversationCount > 0
  const hasStarted = completedCount > 0
  const titleClass = hasStarted ? linkStyles.visited : linkStyles.unvisited
  const counter = conversationCount > 0 ? `${completedCount}/${conversationCount}` : null

  // Progressive color based on completion percentage
  const getCounterClass = () => {
    if (conversationCount === 0) return 'text-zinc-400 dark:text-zinc-500'
    if (isDone) return 'text-emerald-600 dark:text-emerald-400'
    const pct = completedCount / conversationCount
    if (pct === 0) return 'text-zinc-400 dark:text-zinc-500'
    if (pct < 0.5) return 'text-amber-500 dark:text-amber-400'
    return 'text-blue-600 dark:text-blue-400'
  }
  const counterClass = getCounterClass()

  const handleClick = (e) => {
    e.preventDefault()
    onTopicClick?.(topic.code)
  }

  return (
    <TableRow onClick={handleClick} isFirst={index === 0}>
      <TableRowContent title={topic.name} description={topic.description} titleClassName={titleClass} />
      {counter && (
        <span className={`text-[11px] tabular-nums flex-shrink-0 ${counterClass}`}>
          {counter}
        </span>
      )}
    </TableRow>
  )
}

export default TopicRow