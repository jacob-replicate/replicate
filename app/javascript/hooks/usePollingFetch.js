import { useState, useEffect, useRef, useCallback } from 'react'

/**
 * Fetch data and poll while a condition is true.
 *
 * @param {string} url - endpoint to fetch
 * @param {function} shouldPoll - (data) => boolean, return true to keep polling
 * @returns {[object|null, function]} - the fetched data and a refetch function
 */
const usePollingFetch = (url, shouldPoll) => {
  const [data, setData] = useState(null)
  const intervalRef = useRef(500)
  const timeoutRef = useRef(null)

  const poll = useCallback(async () => {
    try {
      const res = await fetch(url, { headers: { 'X-Requested-With': 'XMLHttpRequest' } })
      if (!res.ok) throw new Error(`HTTP ${res.status}`)

      const json = await res.json()
      setData(json)

      if (shouldPoll(json)) {
        timeoutRef.current = setTimeout(poll, intervalRef.current)
        intervalRef.current = Math.min(intervalRef.current * 1.5, 8000)
      }
    } catch (err) {
      console.error('Fetch error:', err)
      timeoutRef.current = setTimeout(poll, intervalRef.current)
      intervalRef.current = Math.min(intervalRef.current * 2, 8000)
    }
  }, [url, shouldPoll])

  const refetch = useCallback(() => {
    clearTimeout(timeoutRef.current)
    intervalRef.current = 500
    poll()
  }, [poll])

  useEffect(() => {
    poll()
    return () => clearTimeout(timeoutRef.current)
  }, [poll])

  return [data, refetch]
}

export default usePollingFetch