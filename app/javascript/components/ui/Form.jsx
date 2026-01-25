import React from 'react'

export const csrfToken = () =>
  document.querySelector('meta[name="csrf-token"]')?.content || ''

export const PostForm = ({ action, className = 'inline', children, onSuccess }) => {
  const handleSubmit = async (e) => {
    e.preventDefault()
    const response = await fetch(action, {
      method: 'POST',
      headers: {
        'X-CSRF-Token': csrfToken(),
        'Accept': 'application/json',
      },
    })
    if (response.ok && onSuccess) {
      onSuccess()
    }
  }

  return (
    <form onSubmit={handleSubmit} className={className}>
      {children}
    </form>
  )
}