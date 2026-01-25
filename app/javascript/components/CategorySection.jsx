import React from 'react'
import TopicRow from './TopicRow'
import TopicDetail from './TopicDetail'
import { Card, CardBody } from './ui'

const CategorySection = ({ name, topics, variant = 'default', expandedTopicCode, onTopicClick, onBackToCategory, onRefetch }) => {
  const headerClass = variant === 'uncategorized'
    ? 'text-[13px] font-medium text-red-500 dark:text-red-400 tracking-wide mb-2'
    : 'text-[15px] font-medium dark:text-white tracking-wide mb-2'

  const cardClass = variant === 'uncategorized'
    ? 'ring-2 ring-red-300/60 dark:ring-red-700/60'
    : ''

  // Check if any topic in this category is expanded
  const expandedTopic = topics.find(t => t.code === expandedTopicCode)

  const handleTopicClick = (topicCode) => {
    onTopicClick(name, topicCode)
  }

  const handleBack = () => {
    onBackToCategory(name)
  }

  return (
    <section>
      {!expandedTopic && <h2 className={headerClass}>{name}</h2>}
      <Card className={cardClass}>
        {expandedTopic ? (
          // Show expanded topic detail inline
          <TopicDetail
            topic={expandedTopic}
            categoryName={name}
            onBack={handleBack}
            onRefetch={onRefetch}
          />
        ) : (
          // Show topic list
          <CardBody>
            {topics.map((topic, i) => (
              <TopicRow
                key={topic.code}
                topic={topic}
                index={i}
                onTopicClick={handleTopicClick}
              />
            ))}
          </CardBody>
        )}
      </Card>
    </section>
  )
}

export default CategorySection