import React from 'react'
import { XIcon } from './Icons'

export const Button = ({ children, variant = 'primary', size = 'md', className = '', ...props }) => {
  const variants = {
    primary: 'bg-emerald-500 hover:bg-emerald-600 text-white',
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

export const IconButton = ({ children, variant = 'primary', className = '', ...props }) => {
  const variants = {
    primary: 'bg-slate-500 hover:bg-slate-600 text-white',
    danger: 'bg-red-500 hover:bg-red-600 text-white',
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

export const DeleteButton = (props) => (
  <IconButton variant="primary" {...props}>
    <XIcon className="w-3.5 h-3.5 text-white" />
  </IconButton>
)