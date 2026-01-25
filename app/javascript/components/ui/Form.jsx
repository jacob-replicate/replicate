import React from 'react'

// CSRF token helper
export const csrfToken = () =>
  document.querySelector('meta[name="csrf-token"]')?.content || ''

// POST form wrapper
export const PostForm = ({ action, className = 'inline', children }) => (
  <form action={action} method="post" className={className}>
    <input type="hidden" name="authenticity_token" value={csrfToken()} />
    {children}
  </form>
)