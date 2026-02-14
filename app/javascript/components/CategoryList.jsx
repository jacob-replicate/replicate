import React, { useState, useCallback } from 'react'
import ReactDOM from 'react-dom/client'
import CategorySection from './CategorySection'
import useGraphPolling from '../hooks/useGraphPolling'
import { INCIDENT_WIDGETS } from './IncidentWidgets'

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

  // Interleave categories with widgets
  const renderWithWidgets = () => {
    const elements = []
    const categories = data.categories
    let widgetIndex = 0

    categories.forEach((category, index) => {
      // Add a widget before each category (if we have one)
      if (widgetIndex < INCIDENT_WIDGETS.length) {
        const Widget = INCIDENT_WIDGETS[widgetIndex]
        elements.push(
          <div key={`widget-${widgetIndex}`} className="my-4">
            <Widget />
          </div>
        )
        widgetIndex++
      }

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
    })

    // Dump any remaining widgets at the end
    while (widgetIndex < INCIDENT_WIDGETS.length) {
      const Widget = INCIDENT_WIDGETS[widgetIndex]
      elements.push(
        <div key={`widget-${widgetIndex}`} className="my-4">
          <Widget />
        </div>
      )
      widgetIndex++
    }

    return elements
  }

  return (
    <div className="space-y-4">
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