import React, { useState, useEffect, useRef } from 'react'
import {
  Spinner,
  Button, DeleteButton, IconButton, UndoIcon,
  PostForm,
  TableRow, TableRowContent, TableRowActions,
  linkStyles
} from './ui'

const ExperienceRow = ({ exp, index, topicCode, onRefetch }) => {
  const [confirmingDelete, setConfirmingDelete] = useState(false)
  const [countdown, setCountdown] = useState(5)
  const timerRef = useRef(null)

  const isPopulated = exp.state === 'populated'
  const isPopulating = exp.state === 'populating'

  const titleClass = isPopulated
    ? (exp.visited ? linkStyles.visited : linkStyles.unvisited)
    : (isPopulating ? linkStyles.muted : linkStyles.default)

  const performDelete = async () => {
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

  useEffect(() => {
    if (confirmingDelete) {
      setCountdown(5)
      timerRef.current = setInterval(() => {
        setCountdown(prev => {
          if (prev <= 1) {
            clearInterval(timerRef.current)
            setConfirmingDelete(false)
            performDelete()
            return 5
          }
          return prev - 1
        })
      }, 1000)
    }

    return () => {
      if (timerRef.current) {
        clearInterval(timerRef.current)
      }
    }
  }, [confirmingDelete])

  const handleDeleteClick = () => {
    setConfirmingDelete(true)
  }

  const handleConfirmDelete = () => {
    clearInterval(timerRef.current)
    setConfirmingDelete(false)
    performDelete()
  }

  const handleCancelDelete = () => {
    clearInterval(timerRef.current)
    setConfirmingDelete(false)
  }

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
          ) : confirmingDelete ? (
            <>
              <button
                onClick={handleConfirmDelete}
                className="relative h-8 w-[82px] text-xs font-medium tracking-wide text-white rounded-lg overflow-hidden bg-rose-600 hover:bg-rose-700 transition-colors"
              >
                <span
                  className="absolute inset-0 bg-slate-500 origin-right"
                  style={{
                    animation: 'shrink 5s linear forwards',
                  }}
                />
                <span className="relative">Confirm</span>
                <style>{`
                  @keyframes shrink {
                    from { transform: scaleX(1); }
                    to { transform: scaleX(0); }
                  }
                `}</style>
              </button>
              <IconButton variant="primary" onClick={handleCancelDelete}>
                <UndoIcon className="w-3.5 h-3.5 text-white" />
              </IconButton>
            </>
          ) : window.isAdmin && (
            <>
              <PostForm action={`/${topicCode}/${exp.code}/populate`} onSuccess={onRefetch}>
                <Button>Generate</Button>
              </PostForm>
              <DeleteButton onClick={handleDeleteClick} />
            </>
          )}
        </TableRowActions>
      </TableRow>
    </div>
  )
}

export default ExperienceRow