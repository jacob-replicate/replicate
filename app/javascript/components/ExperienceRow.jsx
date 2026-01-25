import React from 'react'
import {
  Spinner,
  Button, DeleteButton, CountdownConfirmButton,
  PostForm,
  TableRow, TableRowContent, TableRowActions,
  linkStyles
} from './ui'
import { useCountdownDelete } from '../hooks'

const ExperienceRow = ({ exp, index, topicCode, onRefetch }) => {
  const isPopulated = exp.state === 'populated'
  const isPopulating = exp.state === 'populating'

  const titleClass = isPopulated
    ? (exp.visited ? linkStyles.visited : linkStyles.unvisited)
    : (isPopulating ? linkStyles.muted : linkStyles.default)

  const { isConfirming, start, confirm, cancel } = useCountdownDelete({
    onDelete: async () => {
      const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content

      try {
        const response = await fetch(`/${topicCode}/${exp.code}`, {
          method: 'DELETE',
          headers: {
            'X-CSRF-Token': csrfToken,
            'Accept': 'application/json'
          }
        })

        if (response.ok) {
          onRefetch?.()
        } else {
          console.error('Failed to delete experience')
        }
      } catch (error) {
        console.error('Delete failed:', error)
      }
    }
  })

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
          ) : isConfirming ? (
            <CountdownConfirmButton onConfirm={confirm} onCancel={cancel} />
          ) : window.isAdmin && (
            <>
              <PostForm action={`/${topicCode}/${exp.code}/populate`} onSuccess={onRefetch}>
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

export default ExperienceRow