import React from 'react'
import ReactDOM from 'react-dom/client'
import usePollingFetch from '../hooks/usePollingFetch'
import ExperienceRow from './ExperienceRow'
import {
  Spinner, PlusIcon,
  Button,
  PostForm,
  Card, CardHeader, CardBody, CardFooter,
} from './ui'


const isPolling = (data) =>
  data.topic_state === 'populating' ||
  data.experiences?.some(e => e.state === 'populating')

const TopicManager = ({ topicCode }) => {
  const data = usePollingFetch(`/${topicCode}`, isPolling)
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