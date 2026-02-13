import React, { useState, useCallback } from 'react'
import ReactDOM from 'react-dom/client'
import CategorySection from './CategorySection'
import useGraphPolling from '../hooks/useGraphPolling'
import { STRUGGLE_WIDGETS } from './StruggleWidgets'

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

  // Interleave categories with widgets (category -> widget -> category -> widget)
  const renderWithWidgets = () => {
    const elements = []
    const categories = data.categories

    categories.forEach((category, index) => {
      // Add the category
      elements.push(
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
      )

      // Add a widget after each category (except the last), cycling through the 10 variations
      if (index < categories.length - 1 && index < STRUGGLE_WIDGETS.length) {
        const Widget = STRUGGLE_WIDGETS[index]
        elements.push(
          <div key={`widget-${index}`} className="my-2">
            <Widget />
          </div>
        )
      }
    })

    return elements
  }

  return (
    <div className="space-y-8 mt-6">
      {renderWithWidgets()}

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