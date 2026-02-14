import React from 'react'
import TopicRow from './TopicRow'
import TopicDetail from './TopicDetail'
import { Card, CardBody } from './ui'

const CategorySection = ({ name, topics, variant = 'default', expandedTopicCode, onTopicClick, onBackToCategory, onRefetch, isAdmin }) => {
  const headerClass = variant === 'uncategorized'
    ? 'text-[13px] font-medium text-red-500 dark:text-red-400 tracking-wide'
    : 'text-[15px] font-medium dark:text-white tracking-wide'

  const cardClass = variant === 'uncategorized'
    ? 'ring-2 ring-red-300/60 dark:ring-red-700/60'
    : ''

  // Check if any topic in this category is expanded
  const expandedTopic = topics.find(t => t.code === expandedTopicCode)

  // Calculate aggregate progress across all topics
  const totalConversations = topics.reduce((sum, t) => sum + (t.conversation_count || 0), 0)
  const completedConversations = topics.reduce((sum, t) => sum + (t.completed_count || 0), 0)
  const progressPct = totalConversations > 0 ? (completedConversations / totalConversations) * 100 : 0

  // Progress bar color based on completion
  const getProgressColor = () => {
    if (progressPct === 100) return 'bg-emerald-500'
    if (progressPct >= 50) return 'bg-blue-500'
    if (progressPct > 0) return 'bg-amber-500'
    return 'bg-zinc-300 dark:bg-zinc-600'
  }

  const handleTopicClick = (topicCode) => {
    onTopicClick(name, topicCode)
  }

  const handleBack = () => {
    onBackToCategory(name)
  }

  return (
    <section>
      {expandedTopic ? (
        // Show expanded topic detail - TopicDetail handles its own Card + external button
        <TopicDetail
          topic={expandedTopic}
          categoryName={name}
          onBack={handleBack}
          onRefetch={onRefetch}
          isAdmin={isAdmin}
        />
      ) : (
        // Show topic list with inset header
        <Card className={cardClass}>
          <CardBody>
            {/* Category header inside card */}
            <div className="flex items-center justify-between px-4 pt-4 pb-3 border-b border-zinc-100 dark:border-zinc-700/50">
              <h2 className={headerClass}>{name}</h2>
              {progressPct > 0 && (
                <div className="h-1.5 bg-zinc-200 dark:bg-zinc-700 rounded-full overflow-hidden w-[100px]">
                  <div
                    className={`h-full rounded-full transition-all duration-300 ${getProgressColor()}`}
                    style={{ width: `${progressPct}%` }}
                  />
                </div>
              )}
            </div>
            {topics.map((topic, i) => (
              <TopicRow
                key={topic.code}
                topic={topic}
                index={i}
                onTopicClick={handleTopicClick}
              />
            ))}
          </CardBody>
        </Card>
      )}
    </section>
  )
}

export default CategorySection