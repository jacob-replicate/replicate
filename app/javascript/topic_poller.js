/**
 * TopicManager - Fetches topic data and renders the entire experiences UI
 * Single source of truth - ERB just provides the topic code
 */
import { buttons, icons, postForm } from './ui_helpers'

class TopicManager {
  constructor(container, topicCode) {
    this.container = container
    this.topicCode = topicCode
    this.url = `/${topicCode}`
    this.minInterval = 500
    this.maxInterval = 8000
    this.backoffMultiplier = 1.5
    this.currentInterval = this.minInterval
    this.timeoutId = null
    this.previousStates = new Map()
  }

  async init() {
    await this.fetch()
  }

  async fetch() {
    try {
      const response = await fetch(this.url, {
        headers: { 'X-Requested-With': 'XMLHttpRequest' }
      })
      if (!response.ok) throw new Error(`HTTP ${response.status}`)

      const data = await response.json()
      this.render(data)

      const needsPolling = data.topic_state === 'populating' ||
        data.experiences.some(exp => exp.state === 'populating')

      if (needsPolling) {
        this.scheduleNext(data)
      }
    } catch (error) {
      console.error('TopicManager fetch error:', error)
      this.currentInterval = Math.min(this.currentInterval * 2, this.maxInterval)
      this.timeoutId = setTimeout(() => this.fetch(), this.currentInterval)
    }
  }

  scheduleNext(data) {
    let changed = false
    for (const exp of data.experiences) {
      if (this.previousStates.get(exp.code) !== exp.state) changed = true
      this.previousStates.set(exp.code, exp.state)
    }
    this.currentInterval = changed ? this.minInterval : Math.min(this.currentInterval * this.backoffMultiplier, this.maxInterval)
    this.timeoutId = setTimeout(() => this.fetch(), this.currentInterval)
  }

  render(data) {
    const isComplete = data.completed_count === data.experience_count && data.experience_count > 0
    const counterColor = isComplete ? 'text-emerald-600 dark:text-emerald-400' : 'text-zinc-400 dark:text-zinc-500'
    const showGenerating = data.topic_state === 'populating'
    const showEmpty = data.experiences.length === 0 && !showGenerating
    const showAddMore = data.experiences.length > 0 && !showGenerating

    const experiencesHtml = data.experiences.length > 0
      ? `<div class="border-t border-zinc-100 dark:border-zinc-700">${data.experiences.map((exp, i) => this.renderExperienceRow(exp, i)).join('')}</div>`
      : ''

    this.container.className = 'mt-4 space-y-8'
    this.container.innerHTML = `
      <section class="bg-white dark:bg-zinc-800 rounded-md shadow-xs overflow-hidden border-2 border-zinc-300 dark:border-zinc-700">
        <div class="px-4 pt-4 pb-3">
          <div class="flex items-center justify-between gap-3">
            <div>
              <h2 class="text-[15px] font-semibold text-zinc-800 dark:text-zinc-100">${data.topic_name}</h2>
              ${data.topic_description ? `<p class="text-[13px] text-zinc-500 dark:text-zinc-400 mt-0.5">${data.topic_description}</p>` : ''}
            </div>
            ${data.experience_count > 0 ? `<span class="text-[11px] tabular-nums flex-shrink-0 ${counterColor}">${data.completed_count}/${data.experience_count}</span>` : ''}
          </div>
        </div>
        ${experiencesHtml}
        ${showGenerating ? this.renderGeneratingFooter() : ''}
        ${showEmpty ? this.renderEmptyState() : ''}
      </section>
      ${showAddMore ? this.renderAddMoreButton() : ''}
    `
  }

  renderExperienceRow(exp, index) {
    const borderClass = index > 0 ? 'border-t border-zinc-100 dark:border-zinc-700' : ''
    const isPopulated = exp.state === 'populated'
    const isPopulating = exp.state === 'populating'

    // Title styling based on state
    let titleClass = 'text-[14px] '
    if (isPopulated) {
      titleClass += exp.visited ? 'text-purple-600 dark:text-purple-400' : 'text-blue-600 dark:text-blue-400'
    } else if (isPopulating) {
      titleClass += 'text-zinc-500 dark:text-zinc-400'
    } else {
      titleClass += 'text-zinc-600 dark:text-zinc-300'
    }

    const content = `
      <div class="flex-1 min-w-0">
        <div class="${titleClass}">${exp.name}</div>
        ${exp.description ? `<div class="text-[13px] text-zinc-400 dark:text-zinc-500 mt-0.5">${exp.description}</div>` : ''}
      </div>
    `

    // Populated: clickable link, no actions
    if (isPopulated) {
      return `
        <div data-experience-code="${exp.code}" class="${borderClass}">
          <a href="${exp.url}" class="flex items-center px-4 py-2.5 hover:bg-zinc-50 dark:hover:bg-zinc-700/50">
            ${content}
          </a>
        </div>
      `
    }

    // Build action buttons for non-populated states
    let actions = ''
    if (isPopulating) {
      actions = `
        <div class="flex items-center gap-2 text-zinc-400 dark:text-zinc-500">
          ${icons.spinner}
          <span class="text-xs">Generating...</span>
        </div>
      `
    } else if (window.isAdmin) {
      actions = postForm(`/${this.topicCode}/${exp.code}/populate`, buttons.primary('Generate'))
    }

    const hoverClass = !isPopulating ? 'hover:bg-zinc-50 dark:hover:bg-zinc-700/50' : ''

    return `
      <div data-experience-code="${exp.code}" class="${borderClass} ${hoverClass} transition-colors">
        <div class="px-4 py-3">
          <div class="flex items-center justify-between gap-3">
            ${content}
            <div class="flex items-center gap-2">
              ${actions}
              ${buttons.delete(`data-delete-experience data-topic-code="${this.topicCode}" data-experience-code="${exp.code}" data-experience-name="${exp.name}"`)}
            </div>
          </div>
        </div>
      </div>
    `
  }


  renderGeneratingFooter() {
    return `
      <div class="border-t border-zinc-100 dark:border-zinc-700">
        <div class="px-4 py-3 flex items-center justify-center gap-2 text-zinc-500 dark:text-zinc-400">
          ${icons.spinner}
          <span class="text-sm">Generating experiences...</span>
        </div>
      </div>
    `
  }

  renderEmptyState() {
    const populateButton = window.isAdmin
      ? postForm(`/${this.topicCode}/populate`, buttons.primary('Generate'))
      : ''
    return `
      <div class="border-t border-zinc-100 dark:border-zinc-700">
        <div class="px-4 py-3 flex items-center justify-between">
          <span class="text-zinc-500 dark:text-zinc-400 text-sm">No experiences yet.</span>
          ${populateButton}
        </div>
      </div>
    `
  }

  renderAddMoreButton() {
    return `
      <div class="flex justify-center">
        <button type="button" class="inline-flex items-center gap-1.5 px-3 py-1.5 text-sm font-medium text-white bg-blue-500 hover:bg-blue-600 rounded-md shadow-sm transition-colors">
          ${icons.plus}
          <span>Add more experiences</span>
        </button>
      </div>
    `
  }
}

document.addEventListener('DOMContentLoaded', () => {
  const container = document.querySelector('[data-topic-code]')
  if (!container) return
  new TopicManager(container, container.dataset.topicCode).init()
})

export default TopicManager