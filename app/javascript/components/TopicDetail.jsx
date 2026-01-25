import React from 'react'
import usePollingFetch from '../hooks/usePollingFetch'
import ExperienceRow from './ExperienceRow'
import {
  Spinner, PlusIcon,
  Button,
  PostForm,
  CardBody, CardFooter,
} from './ui'

const isPolling = (data) =>
  data.topic_state === 'populating' ||
  data.experiences?.some(e => e.state === 'populating')

const TopicDetail = ({ topicCode, topicName, onBack }) => {
  const [data, refetch] = usePollingFetch(`/${topicCode}`, isPolling)

  if (!data) {
    return (
      <CardBody>
        <div className="px-4 py-3 flex items-center gap-2 text-zinc-400 dark:text-zinc-500">
          <Spinner />
          <span className="text-sm">Loading...</span>
        </div>
      </CardBody>
    )
  }

  const isComplete = data.completed_count === data.experience_count && data.experience_count > 0
  const showGenerating = data.topic_state === 'populating'
  const showEmpty = data.experiences.length === 0 && !showGenerating
  const counter = data.experience_count > 0 ? `${data.completed_count}/${data.experience_count}` : null

  const counterColor = isComplete
    ? 'text-emerald-600 dark:text-emerald-400'
    : 'text-zinc-400 dark:text-zinc-500'

  return (
    <>
      {/* Topic header with back button */}
      <div className="px-4 pt-3 pb-2 border-b border-zinc-100 dark:border-zinc-700 bg-zinc-50/50 dark:bg-zinc-700/30">
        <div className="flex items-center justify-between gap-3">
          <div className="flex items-center gap-2 min-w-0">
            <button
              onClick={onBack}
              className="text-blue-600 dark:text-blue-400 hover:text-blue-700 dark:hover:text-blue-300 text-[13px] flex-shrink-0"
            >
              ← Back
            </button>
            <span className="text-zinc-300 dark:text-zinc-600">•</span>
            <span className="text-[14px] font-medium text-zinc-800 dark:text-zinc-100 truncate">
              {data.topic_name}
            </span>
          </div>
          {counter && (
            <span className={`text-[11px] tabular-nums flex-shrink-0 ${counterColor}`}>
              {counter}
            </span>
          )}
        </div>
        {data.topic_description && (
          <p className="text-[13px] text-zinc-500 dark:text-zinc-400 mt-1 ml-0">
            {data.topic_description}
          </p>
        )}
      </div>

      {/* Experience list */}
      {data.experiences.length > 0 && (
        <CardBody>
          {data.experiences.map((exp, i) => (
            <ExperienceRow key={exp.code} exp={exp} index={i} topicCode={topicCode} onRefetch={refetch} />
          ))}
        </CardBody>
      )}

      {/* Generating state */}
      {showGenerating && (
        <CardFooter centered>
          <Spinner />
          <span className="text-sm text-zinc-500 dark:text-zinc-400">Generating experiences...</span>
        </CardFooter>
      )}

      {/* Empty state */}
      {showEmpty && (
        <CardFooter>
          <span className="text-zinc-500 dark:text-zinc-400 text-sm">No experiences yet.</span>
          {window.isAdmin && (
            <PostForm action={`/${topicCode}/populate`} onSuccess={refetch}>
              <Button>Generate</Button>
            </PostForm>
          )}
        </CardFooter>
      )}

      {/* Add more button */}
      {data.experiences.length > 0 && !showGenerating && (
        <div className="px-4 py-3 border-t border-zinc-100 dark:border-zinc-700 flex justify-center">
          <Button variant="secondary" className="inline-flex items-center gap-1.5">
            <PlusIcon />
            <span>Add more experiences</span>
          </Button>
        </div>
      )}
    </>
  )
}

export default TopicDetail