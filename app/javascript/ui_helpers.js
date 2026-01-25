/**
 * Shared UI component helpers for consistent styling across JS-rendered UI
 */

export const buttons = {
  primary(text) {
    return `<button type="submit" class="rounded bg-zinc-600 hover:bg-zinc-700 px-3 py-1.5 text-sm font-medium text-white transition-colors">${text}</button>`
  },

  delete(dataAttrs = '') {
    return `
      <button type="button" class="flex-shrink-0 bg-slate-600 hover:bg-slate-700 rounded p-1.5 transition-colors" ${dataAttrs}>
        <svg class="w-3.5 h-3.5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
        </svg>
      </button>
    `
  }
}

export const icons = {
  spinner: `<svg class="w-4 h-4 animate-spin" fill="none" viewBox="0 0 24 24">
    <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="2"></circle>
    <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
  </svg>`,

  plus: `<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/>
  </svg>`
}

export function csrfToken() {
  return document.querySelector('meta[name="csrf-token"]')?.content || ''
}

export function postForm(action, buttonHtml) {
  return `
    <form action="${action}" method="post" class="inline">
      <input type="hidden" name="authenticity_token" value="${csrfToken()}">
      ${buttonHtml}
    </form>
  `
}