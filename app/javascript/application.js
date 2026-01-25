import React from 'react'
import ReactDOM from 'react-dom'
import "./components"
import "./channels/consumer"
import "./topic_poller"

// Reload page on back button to show fresh data
window.addEventListener('pageshow', (event) => {
  if (event.persisted) {
    window.location.reload()
  }
})