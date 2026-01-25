import React from 'react'
import { XIcon } from './Icons'

// Primary action button (gray)
export const Button = ({ children, variant = 'primary', size = 'md', className = '', ...props }) => {
  const variants = {
    primary: 'bg-zinc-600 hover:bg-zinc-700 text-white',
    secondary: 'bg-blue-500 hover:bg-blue-600 text-white',
    danger: 'bg-red-500 hover:bg-red-600 text-white',
  }

  const sizes = {
    sm: 'px-2.5 py-1 text-xs',
    md: 'px-3 py-1.5 text-sm',
    lg: 'px-4 py-2 text-base',
  }

  return (
    <button
      type="submit"
      className={`rounded font-medium transition-colors ${variants[variant]} ${sizes[size]} ${className}`}
      {...props}
    >
      {children}
    </button>
  )
}

// Icon-only button (for delete, close, etc.)
export const IconButton = ({ children, variant = 'primary', className = '', ...props }) => {
  const variants = {
    primary: 'bg-slate-600 hover:bg-slate-700',
    danger: 'bg-red-500 hover:bg-red-600',
    ghost: 'hover:bg-zinc-100 dark:hover:bg-zinc-700',
  }

  return (
    <button
      type="button"
      className={`flex-shrink-0 rounded p-1.5 transition-colors ${variants[variant]} ${className}`}
      {...props}
    >
      {children}
    </button>
  )
}

// Delete button with X icon
export const DeleteButton = (props) => (
  <IconButton variant="primary" {...props}>
    <XIcon className="w-3.5 h-3.5 text-white" />
  </IconButton>
)