import React, { useState, useEffect } from 'react'
import ReactDOM from 'react-dom/client'
import TopicRow from './TopicRow'
import { Card, CardBody } from './ui'

const CategorySection = ({ name, topics, variant = 'default' }) => {
  const headerClass = variant === 'uncategorized'
    ? 'text-[13px] font-medium text-red-500 dark:text-red-400 tracking-wide mb-2'
    : 'text-[15px] font-medium dark:text-white tracking-wide mb-2'

  const cardClass = variant === 'uncategorized'
    ? 'ring-2 ring-red-300/60 dark:ring-red-700/60'
    : ''

  return (
    <section>
      <h2 className={headerClass}>{name}</h2>
      <Card className={cardClass}>
        <CardBody>
          {topics.map((topic, i) => (
            <TopicRow key={topic.code} topic={topic} index={i} />
          ))}
        </CardBody>
      </Card>
    </section>
  )
}

const CategoryList = () => {
  const [data, setData] = useState(null)

  useEffect(() => {
    console.log('CategoryList: useEffect running')
    const fetchData = async () => {
      console.log('CategoryList: fetching /')
      try {
        const res = await fetch('/', { headers: { 'X-Requested-With': 'XMLHttpRequest' } })
        console.log('CategoryList: response status', res.status)
        if (res.ok) {
          const json = await res.json()
          console.log('CategoryList: data received', json)
          setData(json)
        } else {
          console.log('CategoryList: response not ok')
        }
      } catch (err) {
        console.error('CategoryList: fetch error', err)
      }
    }
    fetchData()
  }, [])

  console.log('CategoryList: rendering, data =', data)
  if (!data) return null

  return (
    <div className="space-y-8 mt-6">
      {data.categories.map((category) => (
        <CategorySection key={category.name} name={category.name} topics={category.topics} />
      ))}

      {data.uncategorized.length > 0 && (
        <CategorySection name="Uncategorized" topics={data.uncategorized} variant="uncategorized" />
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