// Handle delete experience buttons with clean JS
// Uses event delegation to handle dynamically added buttons
document.addEventListener('DOMContentLoaded', () => {
  document.addEventListener('click', async (e) => {
    const button = e.target.closest('[data-delete-experience]');
    if (!button) return;

    e.preventDefault();

    const topicCode = button.dataset.topicCode;
    const experienceCode = button.dataset.experienceCode;
    const experienceName = button.dataset.experienceName;

    if (!topicCode || !experienceCode) {
      alert('Failed to delete experience');
      return;
    }

    if (!confirm(`Delete "${experienceName}"?`)) return;

    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content;

    try {
      const response = await fetch(`/${topicCode}/${experienceCode}`, {
        method: 'DELETE',
        headers: {
          'X-CSRF-Token': csrfToken,
          'Accept': 'text/html'
        }
      });

      if (response.ok) {
        // Remove the experience row from the DOM
        const experienceRow = button.closest('[data-experience-code]');
        if (experienceRow) {
          experienceRow.remove();
        }
      } else {
        alert('Failed to delete experience');
      }
    } catch (error) {
      console.error('Delete failed:', error);
      alert('Failed to delete experience');
    }
  });
});