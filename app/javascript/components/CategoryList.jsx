import React, { useState, useCallback } from 'react'
import ReactDOM from 'react-dom/client'
import CategorySection from './CategorySection'
import useGraphPolling from '../hooks/useGraphPolling'

const CategoryList = () => {
  const [data, refetch] = useGraphPolling()
  const [expandedByCategory, setExpandedByCategory] = useState({})

  const handleTopicClick = useCallback((categoryName, topicCode) => {
    setExpandedByCategory(prev => ({
      ...prev,
      [categoryName]: topicCode
    }))
  }, [])

  const handleBackToCategory = useCallback((categoryName) => {
    setExpandedByCategory(prev => ({
      ...prev,
      [categoryName]: null
    }))
  }, [])

  if (!data) return null

  const isAdmin = data.is_admin

  return (
    <div className="space-y-8 mt-6">
      {data.categories.map((category) => (
        <CategorySection
          key={category.name}
          name={category.name}
          topics={category.topics}
          expandedTopicCode={expandedByCategory[category.name]}
          onTopicClick={handleTopicClick}
          onBackToCategory={handleBackToCategory}
          onRefetch={refetch}
          isAdmin={isAdmin}
        />
      ))}

      {data.uncategorized.length > 0 && (
        <CategorySection
          name="Uncategorized"
          topics={data.uncategorized}
          variant="uncategorized"
          expandedTopicCode={expandedByCategory['Uncategorized']}
          onTopicClick={handleTopicClick}
          onBackToCategory={handleBackToCategory}
          onRefetch={refetch}
          isAdmin={isAdmin}
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