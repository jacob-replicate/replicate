import React from 'react'
import {
  Spinner,
  Button, DeleteButton, CountdownConfirmButton,
  PostForm,
  TableRow, TableRowContent, TableRowActions,
  linkStyles
} from './ui'
import { useCountdownDelete } from '../hooks'

const ConversationRow = ({ conversation, index, topicCode, onRefetch, isAdmin }) => {
  const isPopulated = conversation.state === 'populated'
  const isPopulating = conversation.state === 'populating'
  const isPending = conversation.state === 'pending'

  const titleClass = isPopulated
    ? (conversation.visited ? linkStyles.visited : linkStyles.unvisited)
    : (isPopulating ? linkStyles.muted : linkStyles.default)

  const { isConfirming, start, confirm, cancel } = useCountdownDelete({
    onDelete: async () => {
      const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content

      try {
        const response = await fetch(`/${topicCode}/${conversation.code}`, {
          method: 'DELETE',
          headers: {
            'X-CSRF-Token': csrfToken,
            'Accept': 'application/json'
          }
        })

        if (response.ok) {
          onRefetch?.()
        } else {
          console.error('Failed to delete conversation')
        }
      } catch (error) {
        console.error('Delete failed:', error)
      }
    }
  })

  // Populated conversations are clickable links
  if (isPopulated) {
    return (
      <TableRow href={conversation.url} isFirst={index === 0} data-conversation-code={conversation.code}>
        <TableRowContent title={conversation.name} description={conversation.description} titleClassName={titleClass} />
      </TableRow>
    )
  }

  // Non-admin users only see pending/populating state without controls
  if (!isAdmin) {
    return (
      <div data-conversation-code={conversation.code}>
        <TableRow isFirst={index === 0}>
          <TableRowContent title={conversation.name} description={conversation.description} titleClassName={titleClass} />
          {isPopulating && (
            <TableRowActions>
              <div className="flex items-center gap-2 text-zinc-400 dark:text-zinc-500">
                <Spinner />
                <span className="text-xs">Generating...</span>
              </div>
            </TableRowActions>
          )}
        </TableRow>
      </div>
    )
  }

  // Admin users see full controls
  return (
    <div data-conversation-code={conversation.code}>
      <TableRow isFirst={index === 0} className={isPopulating ? '!hover:bg-transparent' : ''}>
        <TableRowContent title={conversation.name} description={conversation.description} titleClassName={titleClass} />
        <TableRowActions>
          {isPopulating ? (
            <div className="flex items-center gap-2 text-zinc-400 dark:text-zinc-500">
              <Spinner />
              <span className="text-xs">Generating...</span>
            </div>
          ) : isConfirming ? (
            <CountdownConfirmButton onConfirm={confirm} onCancel={cancel} />
          ) : (
            <>
              <PostForm action={`/${topicCode}/${conversation.code}/populate`} onSuccess={onRefetch}>
                <Button>Generate</Button>
              </PostForm>
              <DeleteButton onClick={start} />
            </>
          )}
        </TableRowActions>
      </TableRow>
    </div>
  )
}

export default ConversationRow