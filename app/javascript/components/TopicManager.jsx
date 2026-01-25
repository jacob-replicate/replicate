import React, { useState, useEffect, useRef } from 'react'
import ReactDOM from 'react-dom/client'
import {
  Spinner, PlusIcon,
  Button, DeleteButton,
  PostForm,
  Card, CardHeader, CardBody, CardFooter,
  TableRow, TableRowContent, TableRowActions,
  linkStyles
} from './ui'

const ExperienceRow = ({ exp, index, topicCode }) => {
  const isPopulated = exp.state === 'populated'
  const isPopulating = exp.state === 'populating'

  let titleClass = isPopulated
    ? (exp.visited ? linkStyles.visited : linkStyles.unvisited)
    : (isPopulating ? linkStyles.muted : linkStyles.default)

  if (isPopulated) {
    return (
      <TableRow href={exp.url} isFirst={index === 0} data-experience-code={exp.code}>
        <TableRowContent title={exp.name} description={exp.description} titleClassName={titleClass} />
      </TableRow>
    )
  }

  return (
    <div data-experience-code={exp.code}>
      <TableRow isFirst={index === 0} className={isPopulating ? '!hover:bg-transparent' : ''}>
        <TableRowContent title={exp.name} description={exp.description} titleClassName={titleClass} />
        <TableRowActions>
          {isPopulating ? (
            <div className="flex items-center gap-2 text-zinc-400 dark:text-zinc-500">
              <Spinner />
              <span className="text-xs">Generating...</span>
            </div>
          ) : window.isAdmin && (
            <PostForm action={`/${topicCode}/${exp.code}/populate`}>
              <Button>Generate</Button>
            </PostForm>
          )}
          <DeleteButton
            data-delete-experience=""
            data-topic-code={topicCode}
            data-experience-code={exp.code}
            data-experience-name={exp.name}
          />
        </TableRowActions>
      </TableRow>
    </div>
  )
}

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
  const showGenerating = data.topic_state === 'populating'
  const showEmpty = data.experiences.length === 0 && !showGenerating
  const showAddMore = data.experiences.length > 0 && !showGenerating
  const counter = data.experience_count > 0 ? `${data.completed_count}/${data.experience_count}` : null

  return (
    <div className="mt-4 space-y-8">
      <Card>
        <CardHeader
          title={data.topic_name}
          description={data.topic_description}
          counter={counter}
          counterComplete={isComplete}
        />

        {data.experiences.length > 0 && (
          <CardBody>
            {data.experiences.map((exp, i) => (
              <ExperienceRow key={exp.code} exp={exp} index={i} topicCode={topicCode} />
            ))}
          </CardBody>
        )}

        {showGenerating && (
          <CardFooter centered>
            <Spinner />
            <span className="text-sm text-zinc-500 dark:text-zinc-400">Generating experiences...</span>
          </CardFooter>
        )}

        {showEmpty && (
          <CardFooter>
            <span className="text-zinc-500 dark:text-zinc-400 text-sm">No experiences yet.</span>
            {window.isAdmin && (
              <PostForm action={`/${topicCode}/populate`}>
                <Button>Generate</Button>
              </PostForm>
            )}
          </CardFooter>
        )}
      </Card>

      {showAddMore && (
        <div className="flex justify-center">
          <Button variant="secondary" className="inline-flex items-center gap-1.5">
            <PlusIcon />
            <span>Add more experiences</span>
          </Button>
        </div>
      )}
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