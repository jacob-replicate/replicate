/**
 * TopicPoller - Polls for topic/experience updates with exponential backoff
 */
class TopicPoller {
  constructor(url, options = {}) {
    this.url = url
    this.minInterval = options.minInterval || 500
    this.maxInterval = options.maxInterval || 8000
    this.backoffMultiplier = options.backoffMultiplier || 1.5
    this.currentInterval = this.minInterval
    this.timeoutId = null
    this.isAdmin = options.isAdmin || false
    this.topicCode = options.topicCode
    this.lastExperienceStates = new Map()
  }

  start() {
    // Initialize state tracking from existing DOM elements
    this.initializeStateFromDOM()
    this.poll()
  }

  initializeStateFromDOM() {
    const list = document.querySelector('[data-experiences-list]')
    if (!list) return

    list.querySelectorAll('[data-experience-code]').forEach(row => {
      const code = row.getAttribute('data-experience-code')
      const state = row.getAttribute('data-experience-state')
      if (code && state) {
        this.lastExperienceStates.set(code, state)
      }
    })
  }

  stop() {
    if (this.timeoutId) {
      clearTimeout(this.timeoutId)
      this.timeoutId = null
    }
  }

  async poll() {
    try {
      const response = await fetch(this.url, {
        headers: { 'X-Requested-With': 'XMLHttpRequest' }
      })

      if (!response.ok) throw new Error(`HTTP ${response.status}`)

      const data = await response.json()
      const changed = this.updateUI(data)

      // Reset interval if something changed, otherwise backoff
      if (changed) {
        this.currentInterval = this.minInterval
      } else {
        this.currentInterval = Math.min(
          this.currentInterval * this.backoffMultiplier,
          this.maxInterval
        )
      }

      // Stop polling if fully populated
      if (this.isFullyPopulated(data)) {
        this.hideGeneratingFooter()
        return
      }

      this.scheduleNext()
    } catch (error) {
      console.error('TopicPoller error:', error)
      this.currentInterval = Math.min(this.currentInterval * 2, this.maxInterval)
      this.scheduleNext()
    }
  }

  scheduleNext() {
    this.timeoutId = setTimeout(() => this.poll(), this.currentInterval)
  }

  isFullyPopulated(data) {
    return data.topic_state === 'populated' &&
      data.experiences.every(exp => exp.state === 'populated')
  }

  updateUI(data) {
    let changed = false

    // Update counter
    changed = this.updateCounter(data) || changed

    // Update experiences list
    changed = this.updateExperiences(data) || changed

    return changed
  }

  updateCounter(data) {
    const counter = document.querySelector('[data-topic-counter]')
    if (!counter) return false

    const newText = `${data.completed_count}/${data.experience_count}`
    if (counter.textContent.trim() === newText) return false

    counter.textContent = newText

    // Update color if complete
    if (data.completed_count === data.experience_count) {
      counter.classList.remove('text-zinc-400', 'dark:text-zinc-500')
      counter.classList.add('text-emerald-600', 'dark:text-emerald-400')
    }

    return true
  }

  updateExperiences(data) {
    const list = document.querySelector('[data-experiences-list]')
    if (!list) return false

    let changed = false

    // Check for new experiences or state changes
    for (const exp of data.experiences) {
      const existingRow = list.querySelector(`[data-experience-code="${exp.code}"]`)

      if (!existingRow) {
        // New experience - append it
        const row = this.createExperienceRow(exp)
        list.appendChild(row)
        changed = true
      } else {
        // Check for state change
        const prevState = this.lastExperienceStates.get(exp.code)
        if (prevState && prevState !== exp.state) {
          // State changed - replace the row
          const newRow = this.createExperienceRow(exp)
          existingRow.replaceWith(newRow)
          changed = true
        }
      }

      this.lastExperienceStates.set(exp.code, exp.state)
    }


    // Show/hide generating footer based on topic state
    if (data.topic_state === 'populating' && data.experiences.length > 0) {
      this.showExperiencesGeneratingFooter()
    } else if (data.topic_state === 'populated') {
      this.hideGeneratingFooter()
    }

    return changed
  }

  createExperienceRow(exp) {
    const div = document.createElement('div')
    div.setAttribute('data-experience-code', exp.code)
    div.setAttribute('data-experience-state', exp.state)
    div.className = 'border-t border-zinc-100 dark:border-zinc-700'

    if (exp.state === 'populated') {
      const textColor = exp.visited
        ? 'text-purple-600 dark:text-purple-400'
        : 'text-blue-600 dark:text-blue-400'

      div.innerHTML = `
        <a href="${exp.url}" class="block px-4 py-2.5 hover:bg-zinc-50 dark:hover:bg-zinc-700/50">
          <div class="text-[14px] ${textColor}">${exp.name}</div>
          <div class="text-[13px] text-zinc-500 dark:text-zinc-400 mt-0.5">${exp.description}</div>
        </a>
      `
    } else if (exp.state === 'populating') {
      div.innerHTML = `
        <div class="px-4 py-2.5">
          <div class="flex items-center justify-between gap-3">
            <div>
              <div class="text-[14px] text-zinc-500 dark:text-zinc-400">${exp.name}</div>
              <div class="text-[13px] text-zinc-400 dark:text-zinc-500 mt-0.5">${exp.description}</div>
            </div>
            <div class="flex items-center gap-2 text-zinc-400 dark:text-zinc-500">
              <svg class="w-4 h-4 animate-spin" fill="none" viewBox="0 0 24 24">
                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="2"></circle>
                <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
              </svg>
              <span class="text-xs">Populating...</span>
            </div>
          </div>
        </div>
      `
    } else {
      // Pending state
      const adminButton = this.isAdmin ? `
        <form action="/${this.topicCode}/${exp.code}/populate" method="post" data-turbo-confirm="Populate ${exp.name} with elements?">
          <input type="hidden" name="authenticity_token" value="${this.getCSRFToken()}">
          <button type="submit" class="inline-flex items-center gap-1.5 rounded-md border border-zinc-300 dark:border-zinc-600 bg-white dark:bg-zinc-800 hover:bg-zinc-50 dark:hover:bg-zinc-700 px-2.5 py-1 text-xs font-medium text-zinc-700 dark:text-zinc-300 transition-colors">
            <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M12 4v16m8-8H4"/>
            </svg>
            <span>Populate</span>
          </button>
        </form>
      ` : '<span class="text-xs text-zinc-400 dark:text-zinc-500">Coming soon</span>'

      div.innerHTML = `
        <div class="px-4 py-2.5">
          <div class="flex items-center justify-between gap-3">
            <div>
              <div class="text-[14px] text-zinc-500 dark:text-zinc-400">${exp.name}</div>
              <div class="text-[13px] text-zinc-400 dark:text-zinc-500 mt-0.5">${exp.description}</div>
            </div>
            ${adminButton}
          </div>
        </div>
      `
    }

    return div
  }

  showExperiencesGeneratingFooter() {
    const footer = document.querySelector('[data-generating-footer]')
    if (footer) footer.classList.remove('hidden')
  }

  hideGeneratingFooter() {
    const footer = document.querySelector('[data-generating-footer]')
    if (footer) footer.classList.add('hidden')
  }

  getCSRFToken() {
    const meta = document.querySelector('meta[name="csrf-token"]')
    return meta ? meta.getAttribute('content') : ''
  }
}

// Auto-initialize if data attribute present
document.addEventListener('DOMContentLoaded', () => {
  const container = document.querySelector('[data-topic-poller]')
  if (!container) return

  const url = container.dataset.topicPollerUrl
  const isAdmin = container.dataset.topicPollerAdmin === 'true'
  const topicCode = container.dataset.topicPollerCode

  if (!url) return

  const poller = new TopicPoller(url, { isAdmin, topicCode })
  poller.start()
})

export default TopicPoller