/**
 * API layer for conversations
 *
 * All requests include credentials for session-based auth.
 * The server scopes all queries by the current owner (User or Session).
 */

const handleResponse = async (response) => {
  if (!response.ok) {
    const error = new Error(`API error: ${response.status}`)
    error.status = response.status
    try {
      error.body = await response.json()
    } catch {
      error.body = null
    }
    throw error
  }
  return response.json()
}

/**
 * Get all conversations for the current owner
 * @returns {Promise<Array>} Array of conversation objects
 */
export const getConversations = () =>
  fetch('/api/conversations', { credentials: 'include' })
    .then(handleResponse)

/**
 * Get a single conversation with messages
 * @param {string} uuid - Conversation UUID
 * @returns {Promise<Object>} Conversation object with messages
 */
export const getConversation = (uuid) =>
  fetch(`/api/conversations/${uuid}`, { credentials: 'include' })
    .then(handleResponse)

/**
 * Update a conversation (mark as read, mute, etc.)
 * @param {string} uuid - Conversation UUID
 * @param {Object} params - Fields to update
 * @param {string} params.last_read_message_id - Mark messages up to this ID as read
 * @param {boolean} params.muted - Mute/unmute the conversation
 * @returns {Promise<Object>} Updated conversation object
 */
export const updateConversation = (uuid, params) =>
  fetch(`/api/conversations/${uuid}`, {
    method: 'PATCH',
    credentials: 'include',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(params),
  }).then(handleResponse)

/**
 * Create a message in a conversation
 * @param {string} conversationUuid - Conversation UUID
 * @param {string} content - Message content
 * @returns {Promise<Object>} Created message object
 */
export const createMessage = (conversationUuid, content) =>
  fetch(`/api/conversations/${conversationUuid}/messages`, {
    method: 'POST',
    credentials: 'include',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ content }),
  }).then(handleResponse)

/**
 * Mark a conversation as read
 * Convenience wrapper around updateConversation
 * @param {string} uuid - Conversation UUID
 * @param {string} lastMessageId - ID of the last message read
 * @returns {Promise<Object>} Updated conversation object
 */
export const markAsRead = (uuid, lastMessageId) =>
  updateConversation(uuid, { last_read_message_id: lastMessageId })

export default {
  getConversations,
  getConversation,
  updateConversation,
  createMessage,
  markAsRead,
}