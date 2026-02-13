import React from 'react'
import ConversationRow from './ConversationRow'
import {
  Spinner, PlusIcon,
  Button,
  PostForm,
  Card, CardBody, CardFooter,
} from './ui'

const TopicDetail = ({ topic, categoryName, onBack, onRefetch, isAdmin }) => {
  const conversations = topic.conversations || []

  const conversationCount = topic.conversation_count || 0
  const isComplete = topic.completed_count === conversationCount && conversationCount > 0
  const showGenerating = topic.state === 'populating'
  const showEmpty = conversations.length === 0 && !showGenerating
  const counter = conversationCount > 0 ? `${topic.completed_count}/${conversationCount}` : null

  const counterColor = isComplete
    ? 'text-emerald-600 dark:text-emerald-400'
    : 'text-zinc-400 dark:text-zinc-500'

  return (
    <>
      <Card>
          {/* Topic header */}
          <div className="px-4 pt-4 pb-3 border-b border-zinc-100 dark:border-zinc-700">
            <div className="flex items-start justify-between gap-3">
              <div className="min-w-0">
                <h2 className="text-[15px] font-semibold text-zinc-900 dark:text-zinc-50 tracking-tight">
                  {topic.name}
                </h2>
                {topic.description && (
                  <p className="text-[12px] text-zinc-500 dark:text-zinc-400 mt-0.5 leading-relaxed">
                    {topic.description}
                  </p>
                )}
                <button
                  onClick={onBack}
                  className="text-blue-600 dark:text-blue-400 hover:text-blue-700 dark:hover:text-blue-300 text-[13px] mt-2.5 inline-flex items-center gap-1.5 font-medium"
                >
                  <span>←</span>
                  <span>{categoryName || 'Back'}</span>
                </button>
              </div>
              {counter && (
                <span className={`text-[11px] tabular-nums flex-shrink-0 font-medium ${counterColor}`}>
                  {counter}
                </span>
              )}
            </div>
          </div>

          {/* Conversation list */}
          {conversations.length > 0 && (
            <CardBody>
              {conversations.map((convo, i) => (
                <ConversationRow key={convo.code} conversation={convo} index={i} topicCode={topic.code} onRefetch={onRefetch} isAdmin={isAdmin} />
              ))}
            </CardBody>
          )}

          {/* Generating state */}
          {showGenerating && (
            <CardFooter centered>
              <Spinner />
              <span className="text-sm text-zinc-500 dark:text-zinc-400">Generating conversations...</span>
            </CardFooter>
          )}

          {/* Empty state - only show generate button if admin */}
          {showEmpty && (
            <CardFooter>
              <span className="text-zinc-500 dark:text-zinc-400 text-sm">No conversations yet.</span>
              {isAdmin && (
                <PostForm action={`/${topic.code}/populate`} onSuccess={onRefetch}>
                  <Button>Generate</Button>
                </PostForm>
              )}
            </CardFooter>
          )}
        </Card>

      {/* Add more button - outside card, only show if admin */}
      {isAdmin && conversations.length > 0 && !showGenerating && (
        <div className="mt-3 flex justify-end">
          <button className="inline-flex items-center gap-1.5 px-3 py-1.5 text-[12px] font-medium rounded-md bg-slate-800 text-white hover:bg-slate-700 dark:bg-slate-600 dark:hover:bg-slate-500 transition-colors">
            <PlusIcon />
            <span>Add more conversations</span>
          </button>
        </div>
      )}
    </>
  )
}

export default TopicDetail