import { useState, useEffect, useRef, useCallback } from 'react'

/**
 * Hook for countdown-based delete confirmation
 * @param {Object} options
 * @param {Function} options.onDelete - Async function to perform the delete
 * @param {number} options.duration - Countdown duration in seconds (default: 5)
 * @returns {Object} - { isConfirming, countdown, start, confirm, cancel }
 */
export const useCountdownDelete = ({ onDelete, duration = 5 }) => {
  const [isConfirming, setIsConfirming] = useState(false)
  const [countdown, setCountdown] = useState(duration)
  const timerRef = useRef(null)
  const onDeleteRef = useRef(onDelete)

  // Keep onDelete ref up to date
  useEffect(() => {
    onDeleteRef.current = onDelete
  }, [onDelete])

  const performDelete = useCallback(async () => {
    await onDeleteRef.current?.()
  }, [])

  useEffect(() => {
    if (isConfirming) {
      setCountdown(duration)
      timerRef.current = setInterval(() => {
        setCountdown(prev => {
          if (prev <= 1) {
            clearInterval(timerRef.current)
            setIsConfirming(false)
            performDelete()
            return duration
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
  }, [isConfirming, duration, performDelete])

  const start = useCallback(() => {
    setIsConfirming(true)
  }, [])

  const confirm = useCallback(() => {
    clearInterval(timerRef.current)
    setIsConfirming(false)
    performDelete()
  }, [performDelete])

  const cancel = useCallback(() => {
    clearInterval(timerRef.current)
    setIsConfirming(false)
  }, [])

  return {
    isConfirming,
    countdown,
    start,
    confirm,
    cancel,
  }
}