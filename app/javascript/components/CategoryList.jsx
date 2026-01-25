import React, { useState, useCallback } from 'react'
import ReactDOM from 'react-dom/client'
import CategorySection from './CategorySection'
import useGraphPolling from '../hooks/useGraphPolling'

const CategoryList = () => {
  const [data, refetch] = useGraphPolling()
  const [expandedTopicCode, setExpandedTopicCode] = useState(null)

  const handleTopicClick = useCallback((topicCode) => {
    setExpandedTopicCode(topicCode)
  }, [])

  const handleBackToCategory = useCallback(() => {
    setExpandedTopicCode(null)
  }, [])

  if (!data) return null

  return (
    <div className="space-y-8 mt-6">
      {data.categories.map((category) => (
        <CategorySection
          key={category.name}
          name={category.name}
          topics={category.topics}
          expandedTopicCode={expandedTopicCode}
          onTopicClick={handleTopicClick}
          onBackToCategory={handleBackToCategory}
          onRefetch={refetch}
        />
      ))}

      {data.uncategorized.length > 0 && (
        <CategorySection
          name="Uncategorized"
          topics={data.uncategorized}
          variant="uncategorized"
          expandedTopicCode={expandedTopicCode}
          onTopicClick={handleTopicClick}
          onBackToCategory={handleBackToCategory}
          onRefetch={refetch}
        />
      )}
    </div>
  )
}

const mount = () => {
  const container = document.querySelector('[data-category-list]')
  if (!container) return

  const root = ReactDOM.createRoot(container)
  root.render(<CategoryList />)
}

if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', mount)
} else {
  mount()
}

export default CategoryList