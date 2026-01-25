import React from 'react'
import { TableRow, TableRowContent, linkStyles } from './ui'

const TopicRow = ({ topic, index, onTopicClick }) => {
  const isDone = topic.completed === topic.total && topic.total > 0
  const titleClass = topic.visited ? linkStyles.visited : linkStyles.unvisited
  const counter = topic.total > 0 ? `${topic.completed}/${topic.total}` : null
  const counterClass = isDone
    ? 'text-emerald-600 dark:text-emerald-400'
    : 'text-zinc-400 dark:text-zinc-500'

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