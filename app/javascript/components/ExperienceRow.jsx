import React from 'react'
import {
  Spinner,
  Button, DeleteButton,
  PostForm,
  TableRow, TableRowContent, TableRowActions,
  linkStyles
} from './ui'

const ExperienceRow = ({ exp, index, topicCode, onRefetch }) => {
  const isPopulated = exp.state === 'populated'
  const isPopulating = exp.state === 'populating'

  const titleClass = isPopulated
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
            <PostForm action={`/${topicCode}/${exp.code}/populate`} onSuccess={onRefetch}>
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

export default ExperienceRow