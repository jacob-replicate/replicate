/**
 * TopicManager - Fetches topic data and renders the entire experiences UI
 * Single source of truth - ERB just provides the topic code
 */
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

    if (exp.state === 'populated') {
      const textColor = exp.visited ? 'text-purple-600 dark:text-purple-400' : 'text-blue-600 dark:text-blue-400'
      return `
        <div data-experience-code="${exp.code}" class="${borderClass}">
          <a href="${exp.url}" class="block px-4 py-2.5 hover:bg-zinc-50 dark:hover:bg-zinc-700/50">
            <div class="text-[14px] ${textColor}">${exp.name}</div>
            <div class="text-[13px] text-zinc-500 dark:text-zinc-400 mt-0.5">${exp.description}</div>
          </a>
        </div>
      `
    } else if (exp.state === 'populating') {
      return `
        <div data-experience-code="${exp.code}" class="${borderClass}">
          <div class="px-4 py-2.5">
            <div class="flex items-center justify-between gap-3">
              <div class="flex-1 min-w-0">
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
              ${this.renderDeleteButton(exp)}
            </div>
          </div>
        </div>
      `
    } else {
      const populateButton = window.isAdmin ? `
        <form action="/${this.topicCode}/${exp.code}/populate" method="post">
          <input type="hidden" name="authenticity_token" value="${this.csrfToken}">
          <button type="submit" class="inline-flex items-center gap-1.5 rounded-md bg-gradient-to-r from-violet-500 to-purple-500 hover:from-violet-600 hover:to-purple-600 px-3 py-1.5 text-xs font-semibold text-white shadow-sm hover:shadow-md transition-all duration-200 hover:scale-105">
            <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 3v4M3 5h4M6 17v4m-2-2h4m5-16l2.286 6.857L21 12l-5.714 2.143L13 21l-2.286-6.857L5 12l5.714-2.143L13 3z"/>
            </svg>
            <span>Generate</span>
          </button>
        </form>
      ` : ''
      return `
        <div data-experience-code="${exp.code}" class="${borderClass} group hover:bg-gradient-to-r hover:from-violet-50/50 hover:to-purple-50/50 dark:hover:from-violet-900/10 dark:hover:to-purple-900/10 transition-colors duration-200">
          <div class="px-4 py-3">
            <div class="flex items-center justify-between gap-3">
              <div class="flex-1 min-w-0">
                <div class="text-[14px] text-zinc-600 dark:text-zinc-300 group-hover:text-zinc-800 dark:group-hover:text-zinc-100 transition-colors">${exp.name}</div>
                <div class="text-[13px] text-zinc-400 dark:text-zinc-500 mt-0.5">${exp.description}</div>
              </div>
              <div class="flex items-center gap-2">
                ${populateButton}
                ${this.renderDeleteButton(exp)}
              </div>
            </div>
          </div>
        </div>
      `
    }
  }

  renderDeleteButton(exp) {
    return `
      <button type="button" class="flex-shrink-0 bg-slate-600 hover:bg-slate-700 rounded transition-colors" style="padding: 5px 6px;"
              data-delete-experience data-topic-code="${this.topicCode}" data-experience-code="${exp.code}" data-experience-name="${exp.name}">
        <svg class="w-3.5 h-3.5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
        </svg>
      </button>
    `
  }

  renderGeneratingFooter() {
    return `
      <div class="border-t border-zinc-100 dark:border-zinc-700">
        <div class="px-4 py-3 flex items-center justify-center gap-2 text-zinc-500 dark:text-zinc-400">
          <svg class="w-4 h-4 animate-spin" fill="none" viewBox="0 0 24 24">
            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="2"></circle>
            <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
          </svg>
          <span class="text-sm">Generating experiences...</span>
        </div>
      </div>
    `
  }

  renderEmptyState() {
    const populateButton = window.isAdmin ? `
      <form action="/${this.topicCode}/populate" method="post">
        <input type="hidden" name="authenticity_token" value="${this.csrfToken}">
        <button type="submit" class="inline-flex items-center gap-1.5 rounded-md bg-gradient-to-r from-violet-500 to-purple-500 hover:from-violet-600 hover:to-purple-600 px-3.5 py-2 text-sm font-semibold text-white shadow-sm hover:shadow-md transition-all duration-200 hover:scale-105">
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 3v4M3 5h4M6 17v4m-2-2h4m5-16l2.286 6.857L21 12l-5.714 2.143L13 21l-2.286-6.857L5 12l5.714-2.143L13 3z"/>
          </svg>
          <span>Generate Experiences</span>
        </button>
      </form>
    ` : ''
    return `
      <div class="border-t border-zinc-100 dark:border-zinc-700">
        <div class="px-4 py-6 flex flex-col items-center justify-center gap-3">
          <p class="text-zinc-500 dark:text-zinc-400 text-sm">Ready to explore this topic?</p>
          ${populateButton}
        </div>
      </div>
    `
  }

  renderAddMoreButton() {
    return `
      <div class="flex justify-center">
        <button type="button" class="inline-flex items-center gap-1.5 px-3 py-1.5 text-sm font-medium text-white bg-blue-500 hover:bg-blue-600 rounded-md shadow-sm transition-colors">
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/>
          </svg>
          <span>Add more experiences</span>
        </button>
      </div>
    `
  }

  get csrfToken() {
    return document.querySelector('meta[name="csrf-token"]')?.content || ''
  }
}

document.addEventListener('DOMContentLoaded', () => {
  const container = document.querySelector('[data-topic-code]')
  if (!container) return
  new TopicManager(container, container.dataset.topicCode).init()
})

export default TopicManager