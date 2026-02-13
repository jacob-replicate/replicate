import React, { useState, useCallback, useMemo } from 'react'
import ReactDOM from 'react-dom/client'
import CategorySection from './CategorySection'
import useGraphPolling from '../hooks/useGraphPolling'
import { INCIDENT_WIDGETS } from './IncidentWidgets'  // Polished keepers

// Simple seeded random for consistent daily shuffles
const seededRandom = (seed) => {
  const x = Math.sin(seed) * 10000
  return x - Math.floor(x)
}

const shuffleWithSeed = (array, seed) => {
  const shuffled = [...array]
  for (let i = shuffled.length - 1; i > 0; i--) {
    const j = Math.floor(seededRandom(seed + i) * (i + 1))
    ;[shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]]
  }
  return shuffled
}

const CategoryList = () => {
  const [data, refetch] = useGraphPolling()
  const [expandedByCategory, setExpandedByCategory] = useState({})

  // Shuffle polished widgets daily
  const shuffledWidgets = useMemo(() => {
    const allWidgets = [...INCIDENT_WIDGETS]
    const today = new Date()
    const seed = today.getFullYear() * 10000 + (today.getMonth() + 1) * 100 + today.getDate()
    return shuffleWithSeed(allWidgets, seed)
  }, [])

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

  // Interleave categories with randomly shuffled widgets
  const renderWithWidgets = () => {
    const elements = []
    const categories = data.categories
    let widgetIndex = 0

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

      // Add a widget after each category (except the last)
      if (index < categories.length - 1 && widgetIndex < shuffledWidgets.length) {
        const Widget = shuffledWidgets[widgetIndex]
        elements.push(
          <div key={`widget-${widgetIndex}`} className="my-2">
            <Widget />
          </div>
        )
        widgetIndex++
      }
    })

    // Dump any remaining widgets at the end
    while (widgetIndex < shuffledWidgets.length) {
      const Widget = shuffledWidgets[widgetIndex]
      elements.push(
        <div key={`widget-${widgetIndex}`} className="my-2">
          <Widget />
        </div>
      )
      widgetIndex++
    }

    return elements
  }

  return (
    <div className="space-y-4 mt-6">
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