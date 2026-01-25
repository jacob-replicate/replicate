import React, { useState, useEffect, useRef } from 'react'
import ReactDOM from 'react-dom/client'

const Spinner = () => (
  <svg className="w-4 h-4 animate-spin" fill="none" viewBox="0 0 24 24">
    <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="2" />
    <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z" />
  </svg>
)

const PrimaryButton = ({ children, ...props }) => (
  <button
    type="submit"
    className="rounded bg-zinc-600 hover:bg-zinc-700 px-3 py-1.5 text-sm font-medium text-white transition-colors"
    {...props}
  >
    {children}
  </button>
)

const DeleteButton = (props) => (
  <button
    type="button"
    className="flex-shrink-0 bg-slate-600 hover:bg-slate-700 rounded p-1.5 transition-colors"
    {...props}
  >
    <svg className="w-3.5 h-3.5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M6 18L18 6M6 6l12 12" />
    </svg>
  </button>
)

const PostForm = ({ action, children }) => {
  const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content || ''
  return (
    <form action={action} method="post" className="inline">
      <input type="hidden" name="authenticity_token" value={csrfToken} />
      {children}
    </form>
  )
}

const ExperienceRow = ({ exp, index, topicCode }) => {
  const isPopulated = exp.state === 'populated'
  const isPopulating = exp.state === 'populating'
  const borderClass = index > 0 ? 'border-t border-zinc-100 dark:border-zinc-700' : ''

  let titleClass = 'text-[14px] '
  if (isPopulated) {
    titleClass += exp.visited ? 'text-purple-600 dark:text-purple-400' : 'text-blue-600 dark:text-blue-400'
  } else if (isPopulating) {
    titleClass += 'text-zinc-500 dark:text-zinc-400'
  } else {
    titleClass += 'text-zinc-600 dark:text-zinc-300'
  }

  const content = (
    <div className="flex-1 min-w-0">
      <div className={titleClass}>{exp.name}</div>
      {exp.description && (
        <div className="text-[13px] text-zinc-400 dark:text-zinc-500 mt-0.5">{exp.description}</div>
      )}
    </div>
  )

  if (isPopulated) {
    return (
      <div data-experience-code={exp.code} className={borderClass}>
        <a href={exp.url} className="flex items-center px-4 py-2.5 hover:bg-zinc-50 dark:hover:bg-zinc-700/50">
          {content}
        </a>
      </div>
    )
  }

  const hoverClass = !isPopulating ? 'hover:bg-zinc-50 dark:hover:bg-zinc-700/50' : ''

  return (
    <div data-experience-code={exp.code} className={`${borderClass} ${hoverClass} transition-colors`}>
      <div className="px-4 py-3">
        <div className="flex items-center justify-between gap-3">
          {content}
          <div className="flex items-center gap-2">
            {isPopulating ? (
              <div className="flex items-center gap-2 text-zinc-400 dark:text-zinc-500">
                <Spinner />
                <span className="text-xs">Generating...</span>
              </div>
            ) : window.isAdmin && (
              <PostForm action={`/${topicCode}/${exp.code}/populate`}>
                <PrimaryButton>Generate</PrimaryButton>
              </PostForm>
            )}
            <DeleteButton
              data-delete-experience
              data-topic-code={topicCode}
              data-experience-code={exp.code}
              data-experience-name={exp.name}
            />
          </div>
        </div>
      </div>
    </div>
  )
}

const GeneratingFooter = () => (
  <div className="border-t border-zinc-100 dark:border-zinc-700">
    <div className="px-4 py-3 flex items-center justify-center gap-2 text-zinc-500 dark:text-zinc-400">
      <Spinner />
      <span className="text-sm">Generating experiences...</span>
    </div>
  </div>
)

const EmptyState = ({ topicCode }) => (
  <div className="border-t border-zinc-100 dark:border-zinc-700">
    <div className="px-4 py-3 flex items-center justify-between">
      <span className="text-zinc-500 dark:text-zinc-400 text-sm">No experiences yet.</span>
      {window.isAdmin && (
        <PostForm action={`/${topicCode}/populate`}>
          <PrimaryButton>Generate</PrimaryButton>
        </PostForm>
      )}
    </div>
  </div>
)

const AddMoreButton = () => (
  <div className="flex justify-center">
    <button
      type="button"
      className="inline-flex items-center gap-1.5 px-3 py-1.5 text-sm font-medium text-white bg-blue-500 hover:bg-blue-600 rounded-md shadow-sm transition-colors"
    >
      <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 4v16m8-8H4" />
      </svg>
      <span>Add more experiences</span>
    </button>
  </div>
)

const TopicManager = ({ topicCode }) => {
  const [data, setData] = useState(null)
  const previousStates = useRef(new Map())
  const intervalRef = useRef(500)

  useEffect(() => {
    let timeoutId = null
    let mounted = true

    const fetchData = async () => {
      try {
        const response = await fetch(`/${topicCode}`, {
          headers: { 'X-Requested-With': 'XMLHttpRequest' }
        })
        if (!response.ok) throw new Error(`HTTP ${response.status}`)

        const newData = await response.json()
        if (!mounted) return

        setData(newData)

        const needsPolling = newData.topic_state === 'populating' ||
          newData.experiences.some(exp => exp.state === 'populating')

        if (needsPolling) {
          let changed = false
          for (const exp of newData.experiences) {
            if (previousStates.current.get(exp.code) !== exp.state) changed = true
            previousStates.current.set(exp.code, exp.state)
          }
          intervalRef.current = changed ? 500 : Math.min(intervalRef.current * 1.5, 8000)
          timeoutId = setTimeout(fetchData, intervalRef.current)
        }
      } catch (error) {
        console.error('TopicManager fetch error:', error)
        intervalRef.current = Math.min(intervalRef.current * 2, 8000)
        timeoutId = setTimeout(fetchData, intervalRef.current)
      }
    }

    fetchData()
    return () => {
      mounted = false
      if (timeoutId) clearTimeout(timeoutId)
    }
  }, [topicCode])

  if (!data) return null

  const isComplete = data.completed_count === data.experience_count && data.experience_count > 0
  const counterColor = isComplete ? 'text-emerald-600 dark:text-emerald-400' : 'text-zinc-400 dark:text-zinc-500'
  const showGenerating = data.topic_state === 'populating'
  const showEmpty = data.experiences.length === 0 && !showGenerating
  const showAddMore = data.experiences.length > 0 && !showGenerating

  return (
    <div className="mt-4 space-y-8">
      <section className="bg-white dark:bg-zinc-800 rounded-md shadow-xs overflow-hidden border-2 border-zinc-300 dark:border-zinc-700">
        <div className="px-4 pt-4 pb-3">
          <div className="flex items-center justify-between gap-3">
            <div>
              <h2 className="text-[15px] font-semibold text-zinc-800 dark:text-zinc-100">{data.topic_name}</h2>
              {data.topic_description && (
                <p className="text-[13px] text-zinc-500 dark:text-zinc-400 mt-0.5">{data.topic_description}</p>
              )}
            </div>
            {data.experience_count > 0 && (
              <span className={`text-[11px] tabular-nums flex-shrink-0 ${counterColor}`}>
                {data.completed_count}/{data.experience_count}
              </span>
            )}
          </div>
        </div>

        {data.experiences.length > 0 && (
          <div className="border-t border-zinc-100 dark:border-zinc-700">
            {data.experiences.map((exp, i) => (
              <ExperienceRow key={exp.code} exp={exp} index={i} topicCode={topicCode} />
            ))}
          </div>
        )}

        {showGenerating && <GeneratingFooter />}
        {showEmpty && <EmptyState topicCode={topicCode} />}
      </section>

      {showAddMore && <AddMoreButton />}
    </div>
  )
}

// Mount React component
document.addEventListener('DOMContentLoaded', () => {
  const container = document.querySelector('[data-topic-code]')
  if (!container) return

  const topicCode = container.dataset.topicCode
  const root = ReactDOM.createRoot(container)
  root.render(<TopicManager topicCode={topicCode} />)
})

export default TopicManager