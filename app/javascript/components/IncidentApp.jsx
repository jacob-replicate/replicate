import React from 'react'
import ReactDOM from 'react-dom/client'
import { HashRouter, Routes, Route, Link, useParams, useNavigate } from 'react-router-dom'
import useGraphPolling from '../hooks/useGraphPolling'
import { SlackThread } from './IncidentWidgets'

// Category navigation bar
const CategoryNav = ({ categories, current }) => {
  return (
    <div className="px-4 py-3">
      <div className="bg-zinc-100 dark:bg-zinc-800 rounded-xl border border-zinc-200 dark:border-zinc-700 overflow-hidden">
        <div className="flex flex-wrap md:flex-nowrap">
          {categories.map(cat => {
            const isActive = current === cat.name.toLowerCase()
            return (
              <Link
                key={cat.name}
                to={`/${cat.name.toLowerCase()}`}
                className={`w-1/3 md:w-auto md:flex-1 text-center py-3 px-2 md:px-4 text-[12px] md:text-[13px] tracking-wide cursor-pointer transition-all duration-150 ${
                  isActive
                    ? 'text-white font-medium scale-105'
                    : 'text-zinc-400 hover:text-zinc-500 hover:scale-105 font-light'
                }`}
                style={isActive ? { backgroundColor: '#1a365d' } : {}}
              >
                {cat.name.toLowerCase()}
              </Link>
            )
          })}
        </div>
      </div>
    </div>
  )
}

// Home view - redirects to networking/dns by default (opens the conversation directly)
const HomeView = () => {
  const navigate = useNavigate()
  React.useEffect(() => {
    navigate('/networking/dns', { replace: true })
  }, [navigate])
  return null
}

// Category view - shows topics in a category
const CategoryView = ({ categories }) => {
  const { category } = useParams()
  const navigate = useNavigate()

  const categoryData = categories.find(c => c.name.toLowerCase() === category)

  if (!categoryData) {
    return (
      <div>
        <CategoryNav categories={categories} current={category} />
        <div className="p-4 text-zinc-500">Category not found</div>
      </div>
    )
  }

  return (
    <div>
      <CategoryNav categories={categories} current={category} />
      <div className="p-4">
        <div className="rounded-lg overflow-hidden border border-zinc-300 dark:border-zinc-700 bg-white dark:bg-zinc-900 shadow-sm">
          <div className="px-4 pt-4 pb-3 border-b border-zinc-100 dark:border-zinc-700/50">
            <h2 className="text-[15px] font-medium dark:text-white tracking-wide">{categoryData.name}</h2>
          </div>
          {categoryData.topics.map((topic, i) => (
            <div
              key={topic.code}
              onClick={() => navigate(`/${category}/${topic.code}`)}
              className={`px-4 py-3 cursor-pointer hover:bg-zinc-50 dark:hover:bg-zinc-800 transition-colors ${
                i > 0 ? 'border-t border-zinc-100 dark:border-zinc-800' : ''
              }`}
            >
              <div className="flex items-center justify-between">
                <div>
                  <div className="text-[15px] text-blue-600 dark:text-blue-400 font-medium">{topic.name}</div>
                  <div className="text-[13px] text-zinc-500 dark:text-zinc-400 mt-0.5">{topic.description}</div>
                </div>
                {topic.conversation_count > 0 && (
                  <span className="text-[11px] tabular-nums text-zinc-400 dark:text-zinc-500">
                    {topic.completed_count || 0}/{topic.conversation_count}
                  </span>
                )}
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  )
}

// Topic view - shows conversations in a topic (for now, just shows the SlackThread)
const TopicView = ({ categories }) => {
  const { category, topic } = useParams()

  const categoryData = categories.find(c => c.name.toLowerCase() === category)
  const topicData = categoryData?.topics.find(t => t.code === topic)

  return (
    <div>
      <CategoryNav categories={categories} current={category} />
      <div className="p-4">
        {/* Pass topic info to SlackThread - for now it's still hardcoded but will use this later */}
        <SlackThread category={category} topic={topic} topicName={topicData?.name} />
      </div>
    </div>
  )
}

// Main app with routing
const IncidentApp = () => {
  const [data] = useGraphPolling()

  if (!data) return null

  const categories = data.categories || []

  return (
    <HashRouter>
      <Routes>
        <Route path="/" element={<HomeView categories={categories} />} />
        <Route path="/:category" element={<CategoryView categories={categories} />} />
        <Route path="/:category/:topic" element={<TopicView categories={categories} />} />
      </Routes>
    </HashRouter>
  )
}

// Mount function
const mount = () => {
  const container = document.querySelector('[data-incident-app]')
  if (!container) return

  const root = ReactDOM.createRoot(container)
  root.render(<IncidentApp />)
}

if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', mount)
} else {
  mount()
}

export default IncidentApp