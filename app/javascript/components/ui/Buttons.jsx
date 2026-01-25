import React from 'react'
import { XIcon, UndoIcon } from './Icons'

export const Button = ({ children, variant = 'primary', size = 'md', className = '', ...props }) => {
  const variants = {
    primary: 'bg-slate-600 hover:bg-slate-700 active:bg-slate-800 text-white',
    secondary: 'bg-slate-400 hover:bg-slate-500 active:bg-slate-600 text-white',
    danger: 'bg-slate-500 hover:bg-slate-600 active:bg-slate-700 text-white',
  }

  const sizes = {
    sm: 'h-8 px-3 text-xs',
    md: 'h-8 px-4 text-xs',
    lg: 'h-9 px-5 text-sm',
  }

  return (
    <button
      type="submit"
      className={`inline-flex items-center justify-center rounded-lg font-medium tracking-wide transition-colors duration-150 ${variants[variant]} ${sizes[size]} ${className}`}
      {...props}
    >
      {children}
    </button>
  )
}

export const IconButton = ({ children, variant = 'primary', className = '', ...props }) => {
  const variants = {
    primary: 'bg-slate-600 hover:bg-slate-700 active:bg-slate-800 text-white',
    danger: 'bg-slate-600 hover:bg-rose-600 active:bg-rose-700 text-white',
    ghost: 'hover:bg-slate-100 dark:hover:bg-slate-700/50',
  }

  return (
    <button
      type="button"
      className={`flex-shrink-0 inline-flex items-center justify-center h-8 w-8 rounded-lg transition-colors duration-150 ${variants[variant]} ${className}`}
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

/**
 * Countdown confirm button with visual progress bar
 * Shows a button that auto-confirms when countdown completes
 */
export const CountdownConfirmButton = ({
  onConfirm,
  onCancel,
  duration = 5,
  width = 'w-[88px]',
  label = 'Confirm'
}) => (
  <>
    <button
      onClick={onConfirm}
      className={`relative h-8 ${width} text-xs font-medium tracking-wide text-white rounded-lg overflow-hidden bg-slate-700 hover:bg-slate-800 transition-colors`}
    >
      <span
        className="absolute inset-0 bg-slate-500 origin-right animate-countdown-shrink"
        style={{ animationDuration: `${duration}s` }}
      />
      <span className="relative">{label}</span>
    </button>
    <IconButton variant="primary" onClick={onCancel}>
      <UndoIcon className="w-3.5 h-3.5 text-white" />
    </IconButton>
    <style>{`
      @keyframes countdown-shrink {
        from { transform: scaleX(1); }
        to { transform: scaleX(0); }
      }
      .animate-countdown-shrink {
        animation: countdown-shrink linear forwards;
      }
    `}</style>
  </>
)