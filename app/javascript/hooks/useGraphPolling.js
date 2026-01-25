import { useState, useEffect, useRef, useCallback } from 'react'

const MIN_INTERVAL = 500
const MAX_INTERVAL = 30000
const BACKOFF_MULTIPLIER = 1.5
const IDLE_STOP_AFTER = 5 // Stop polling after this many max-interval polls with no changes

/**
 * Poll for graph data with checksum-based change detection and gradual backoff.
 * - Starts fast (500ms)
 * - Backs off gradually when no changes detected
 * - Resets to fast polling when changes detected or activity triggered
 * - Keeps polling while any topic/experience is in 'populating' state
 * - Stops polling entirely after extended idle period
 */
const useGraphPolling = () => {
  const [data, setData] = useState(null)
  const intervalRef = useRef(MIN_INTERVAL)
  const timeoutRef = useRef(null)
  const lastChecksumRef = useRef(null)
  const idleCountRef = useRef(0)
  const stoppedRef = useRef(false)

  const isPopulating = useCallback((graphData) => {
    if (!graphData) return false

    const allTopics = [
      ...(graphData.categories?.flatMap(c => c.topics) || []),
      ...(graphData.uncategorized || [])
    ]

    return allTopics.some(topic =>
      topic.state === 'populating' ||
      topic.conversations?.some(convo => convo.state === 'populating')
    )
  }, [])

  const poll = useCallback(async () => {
    if (stoppedRef.current) return

    try {
      const res = await fetch('/', { headers: { 'X-Requested-With': 'XMLHttpRequest' } })
      if (!res.ok) throw new Error(`HTTP ${res.status}`)

      const json = await res.json()
      const newChecksum = json.checksum
      const hasChanged = lastChecksumRef.current !== newChecksum
      const generating = isPopulating(json)

      lastChecksumRef.current = newChecksum
      setData(json)

      // Determine next interval and whether to continue
      if (hasChanged || generating) {
        // Reset to fast polling on change or while generating
        intervalRef.current = MIN_INTERVAL
        idleCountRef.current = 0
      } else {
        // Back off gradually when idle
        intervalRef.current = Math.min(intervalRef.current * BACKOFF_MULTIPLIER, MAX_INTERVAL)

        // Count consecutive max-interval polls with no changes
        if (intervalRef.current >= MAX_INTERVAL) {
          idleCountRef.current++
          if (idleCountRef.current >= IDLE_STOP_AFTER) {
            // Stop polling - user can trigger refetch to restart
            stoppedRef.current = true
            return
          }
        }
      }

      timeoutRef.current = setTimeout(poll, intervalRef.current)
    } catch (err) {
      console.error('Graph polling error:', err)
      // Back off on errors
      intervalRef.current = Math.min(intervalRef.current * 2, MAX_INTERVAL)
      timeoutRef.current = setTimeout(poll, intervalRef.current)
    }
  }, [isPopulating])

  // Trigger immediate refetch and reset interval (call after user actions)
  const refetch = useCallback(() => {
    clearTimeout(timeoutRef.current)
    intervalRef.current = MIN_INTERVAL
    idleCountRef.current = 0
    stoppedRef.current = false
    poll()
  }, [poll])

  useEffect(() => {
    poll()
    return () => clearTimeout(timeoutRef.current)
  }, [poll])

  return [data, refetch]
}

export default useGraphPolling