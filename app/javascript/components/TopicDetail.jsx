import React, { useRef, useEffect } from 'react'
import ExperienceRow from './ExperienceRow'
import {
  Spinner, PlusIcon,
  Button,
  PostForm,
  CardBody, CardFooter,
} from './ui'

const TopicDetail = ({ topic, categoryName, onBack, onRefetch }) => {
  const containerRef = useRef(null)
  const hasScrolledRef = useRef(false)

  useEffect(() => {
    // Reset scroll flag when topic changes
    hasScrolledRef.current = false
  }, [topic.code])

  useEffect(() => {
    if (containerRef.current && !hasScrolledRef.current) {
      hasScrolledRef.current = true
      const y = containerRef.current.getBoundingClientRect().top + window.scrollY - 40
      window.scrollTo({ top: y, behavior: 'instant' })
    }
  }, [topic.code])

  const isComplete = topic.completed_count === topic.experience_count && topic.experience_count > 0
  const showGenerating = topic.state === 'populating'
  const showEmpty = topic.experiences.length === 0 && !showGenerating
  const counter = topic.experience_count > 0 ? `${topic.completed_count}/${topic.experience_count}` : null

  const counterColor = isComplete
    ? 'text-emerald-600 dark:text-emerald-400'
    : 'text-zinc-400 dark:text-zinc-500'

  return (
    <div ref={containerRef}>
      {/* Topic header with back button */}
      <div className="px-4 pt-3 pb-2 border-b border-zinc-100 dark:border-zinc-700 bg-zinc-50 dark:bg-zinc-800/50">
        <div className="flex items-center justify-between gap-3">
          <div className="flex items-center gap-2 min-w-0">
            <button
              onClick={onBack}
              className="text-blue-600 dark:text-blue-400 hover:text-blue-700 dark:hover:text-blue-300 text-[13px] flex-shrink-0"
            >
              ← {categoryName || 'Back'}
            </button>
            <span className="text-zinc-300 dark:text-zinc-600">•</span>
            <span className="text-[14px] font-medium text-zinc-800 dark:text-zinc-100 truncate">
              {topic.name}
            </span>
          </div>
          {counter && (
            <span className={`text-[11px] tabular-nums flex-shrink-0 ${counterColor}`}>
              {counter}
            </span>
          )}
        </div>
        {topic.description && (
          <p className="text-[13px] text-zinc-500 dark:text-zinc-400 mt-1 ml-0">
            {topic.description}
          </p>
        )}
      </div>

      {/* Experience list */}
      {topic.experiences.length > 0 && (
        <CardBody>
          {topic.experiences.map((exp, i) => (
            <ExperienceRow key={exp.code} exp={exp} index={i} topicCode={topic.code} onRefetch={onRefetch} />
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
          <PostForm action={`/${topic.code}/populate`} onSuccess={onRefetch}>
            <Button>Generate</Button>
          </PostForm>
        </CardFooter>
      )}

      {/* Add more button */}
      {topic.experiences.length > 0 && !showGenerating && (
        <div className="px-4 py-3 border-t border-zinc-100 dark:border-zinc-700 flex justify-center">
          <Button variant="secondary" className="inline-flex items-center gap-1.5">
            <PlusIcon />
            <span>Add more experiences</span>
          </Button>
        </div>
      )}
    </div>
  )
}

export default TopicDetail