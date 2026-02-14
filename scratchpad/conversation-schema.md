# Conversation Schema Design

Designing from first principles based on the data structures in the demo.

## Core Entities

### 1. Conversation
The top-level container. A single chat thread (like a Slack channel conversation).

```
conversations
├── id (uuid, pk)
├── channel_name (string) - e.g., "#ops-alerts"
├── created_at (timestamp)
├── updated_at (timestamp)
```

### 2. Message
A single message in a conversation. Can be a root message or a thread reply.

```
messages
├── id (uuid, pk)
├── conversation_id (uuid, fk -> conversations)
├── parent_message_id (uuid, nullable, fk -> messages) - if set, this is a thread reply
├── sequence (integer) - global monotonic counter, simple 1, 2, 3, 4...
├── author_name (string)
├── author_avatar (string, url)
├── created_at (timestamp)
├── updated_at (timestamp) - if different from created_at, message was edited
```

**Key insight**: Thread replies are just messages with `parent_message_id` set. No separate "thread" table needed. 

**Sequence is dead simple**: Just a global auto-incrementing integer. No decimals, no gaps, no complexity. DB lock ensures monotonic ordering.

### How Threading Works

Sequence is global across ALL messages (root + thread replies):

```
seq 1: msg_1 (root)
seq 2: msg_2 (root)
seq 3: msg_3 (root)
seq 4: reply to msg_3
seq 5: msg_4 (root)
seq 6: reply to msg_3
seq 7: reply to msg_3
seq 8: msg_5 (root)
```

**Rendering logic** (client-side):
1. Fetch all messages ordered by `sequence`
2. Partition: root messages (`parent_message_id IS NULL`) vs replies (`parent_message_id IS NOT NULL`)
3. Root messages render in sequence order in main chat
4. Replies grouped by `parent_message_id`, ordered by `sequence` (already correct since sequence is global)

That's it. Global sequence solves ordering for both main chat AND threads. No special thread-level ordering needed.

### 3. Component
Messages contain one or more components (text, code, diff, alert, etc.). This is the polymorphic content model.

```
components
├── id (uuid, pk)
├── message_id (uuid, fk -> messages)
├── sequence (decimal) - ordering within the message
├── type (enum: text, code, diff, alert, multiple_choice)
├── content (jsonb) - type-specific payload
├── created_at (timestamp)
```

**Component content by type:**

```json
// type: "text"
{ "content": "CoreDNS pods are OOMKilled..." }

// type: "code"
{ "content": "# /etc/resolv.conf...", "language": "bash" }

// type: "diff"
{
  "filename": "k8s/deployments/payments-api.yaml",
  "lines": [
    { "type": "context", "text": "containers:" },
    { "type": "add", "text": "- name: dns-health-checker" },
    { "type": "remove", "text": "- name: old-sidecar" }
  ]
}

// type: "alert"
{
  "severity": "critical",
  "title": "[SEV-1] DNS resolution failures",
  "description": "Services can't resolve internal hostnames"
}

// type: "multiple_choice"
{
  "question": "What's your next move?",
  "options": [
    { "id": "a", "text": "Scale CoreDNS..." },
    { "id": "b", "text": "Check other services..." }
  ]
}
```

### 4. Reactions

Not a separate table. Just inline on the message:

```json
{
  "id": "msg_3",
  "components": [...],
  "reactions": [
    { "emoji": "💀", "count": 3 },
    { "emoji": "🤦", "count": 2 }
  ]
}
```

Pre-baked. No user interaction needed.

### 5. Multiple Choice Selections

Not a separate table. When a user selects an option, update the component's JSONB:

```json
// Before selection
{
  "type": "multiple_choice",
  "question": "What's your next move?",
  "options": [
    { "id": "a", "text": "Scale CoreDNS..." },
    { "id": "b", "text": "Check other services..." }
  ]
}

// After selection - just add selected_option_id
{
  "type": "multiple_choice",
  "question": "What's your next move?",
  "options": [
    { "id": "a", "text": "Scale CoreDNS..." },
    { "id": "b", "text": "Check other services..." }
  ],
  "selected_option_id": "a"
}
```

Simple UPDATE to the component. No extra table.

---

## Alternative: Denormalized Messages

For simpler querying and real-time streaming, consider storing components inline:

```
messages
├── id (uuid, pk)
├── conversation_id (uuid, fk)
├── parent_message_id (uuid, nullable, fk)
├── sequence (integer)
├── author (jsonb) - { "name": "maya", "avatar": "/profile-photo-3.jpg" }
├── components (jsonb[]) - array of component objects
├── created_at (timestamp)
├── updated_at (timestamp)
```

**Pros:**
- Single query to fetch a message with all its content
- Easier to stream over WebSocket (one payload)
- Matches the JS data structure exactly

**Cons:**
- Harder to query by component type
- Larger row sizes
- Updates to single component require rewriting whole array

---

## Sequence Numbers

Simple monotonic integers. Nothing fancy.

```sql
-- On insert, get next sequence atomically
INSERT INTO messages (id, conversation_id, sequence, ...)
VALUES (
  gen_random_uuid(),
  $conversation_id,
  (SELECT COALESCE(MAX(sequence), 0) + 1 FROM messages WHERE conversation_id = $conversation_id),
  ...
);
```

Or use a `sequence` column on `conversations` that you increment with each message (single row lock).

**Why not decimals?**
- Decimals suggest you need to insert "between" messages — you don't
- Thread replies don't need to be sequenced relative to their position in the main chat
- Global sequence just tracks arrival order for replay/consistency
- Rendering logic partitions root vs replies anyway

---

## Query Patterns

### Fetch conversation with all messages
```sql
SELECT * FROM messages
WHERE conversation_id = $1
ORDER BY sequence;
```

### Fetch thread replies for a message
```sql
SELECT * FROM messages
WHERE parent_message_id = $1
ORDER BY sequence;
```

### Count replies per message (for "7 replies" display)
```sql
SELECT parent_message_id, count(*) as reply_count
FROM messages
WHERE conversation_id = $1 AND parent_message_id IS NOT NULL
GROUP BY parent_message_id;
```

---

## Real-time Considerations

For WebSocket streaming:
1. New messages broadcast to all subscribers of `conversation_id`
2. Thread replies include `parent_message_id` so clients know where to nest them
3. Sequence enforced server-side with DB locks, clients trust order
4. Reactions come pre-baked on messages, no separate updates needed

---

## API Design

### REST: Page Load (Existing Conversation)

**GET /conversations/:id**

Returns the full conversation state. Client renders immediately, no animations.

```json
{
  "id": "c9f2e8d1-3b4a-5c6d-7e8f-9a0b1c2d3e4f",
  "channel_name": "#ops-alerts",
  "created_at": "2026-02-14T10:30:00Z",
  "updated_at": "2026-02-14T10:42:00Z",
  "messages": [
    {
      "id": "msg_1",
      "sequence": 1,
      "parent_message_id": null,
      "author": { "name": "PagerDuty", "avatar": "/jacob-square.jpg" },
      "components": [
        { "type": "alert", "title": "[SEV-1] DNS failures...", "description": "..." }
      ],
      "reactions": [
        { "emoji": "📌", "count": 1 },
        { "emoji": "👀", "count": 2 }
      ],
      "created_at": "2026-02-14T10:30:00Z",
      "updated_at": "2026-02-14T10:30:00Z"
    },
    {
      "id": "msg_4",
      "sequence": 4,
      "parent_message_id": "msg_3",
      "author": { "name": "sarah", "avatar": "/profile-photo-1.jpg" },
      "components": [
        { "type": "text", "content": "that was me... 😅" }
      ],
      "reactions": [],
      "created_at": "2026-02-14T10:33:00Z",
      "updated_at": "2026-02-14T10:33:00Z"
    }
    // ... all messages in sequence order
  ]
}
```

Client logic:
```js
const conversation = await fetch(`/conversations/${id}`).then(r => r.json())
api.loadMessages(conversation.messages) // Instant render, no animations
```

---

### REST: Create New Conversation

**POST /conversations/generate**

Generates a new conversation (or returns a random one for demo).

```json
// Response
{
  "id": "c9f2e8d1-3b4a-5c6d-7e8f-9a0b1c2d3e4f",
  "channel_name": "#ops-alerts",
  "is_new": true,
  "messages": []
}
```

Client navigates to `/conversations/:id` and subscribes to ActionCable for streaming.

---

### REST: Send Message

**POST /conversations/:id/messages**

```json
// Request
{
  "parent_message_id": null,  // or message ID for thread reply
  "components": [
    { "type": "text", "content": "I think we should scale CoreDNS" }
  ]
}

// Response
{
  "id": "msg_20",
  "sequence": 20,
  "parent_message_id": null,
  "author": { "name": "you", "avatar": "/your-avatar.jpg" },
  "components": [...],
  "reactions": [],
  "created_at": "2026-02-14T10:45:00Z",
  "updated_at": "2026-02-14T10:45:00Z"
}
```

Server broadcasts this to all subscribers via ActionCable.

---


### REST: Select Multiple Choice Option

**PATCH /conversations/:conversation_id/messages/:message_id/components/:index**

```json
// Request
{ "selected_option_id": "a" }

// Response
{ "ok": true }
```

Updates the component's JSONB in place. Server broadcasts update via ActionCable.

---

## ActionCable: Real-time Streaming

### Channel: ConversationChannel

```ruby
# app/channels/conversation_channel.rb
class ConversationChannel < ApplicationCable::Channel
  def subscribed
    @conversation = Conversation.find(params[:id])
    stream_for @conversation
  end
end
```

### Client Subscription

```js
import { createConsumer } from "@rails/actioncable"

const cable = createConsumer()

const subscription = cable.subscriptions.create(
  { channel: "ConversationChannel", id: conversationId },
  {
    received(data) {
      switch (data.type) {
        case 'message':
          // New message (root or thread reply)
          api.addMessage(data.message)
          break
          
        case 'message_update':
          // Message edited or component updated (e.g., multiple choice selection)
          api.updateMessage(data.message_id, data.changes)
          break
          
        case 'typing':
          // Someone is typing
          api.setTyping(data.author)
          break
      }
    }
  }
)
```

### Server Broadcasts

```ruby
# Broadcasting a new message
ConversationChannel.broadcast_to(conversation, {
  type: 'message',
  message: message.as_json
})


# Broadcasting typing indicator
ConversationChannel.broadcast_to(conversation, {
  type: 'typing',
  author: { name: user.name, avatar: user.avatar_url }
})

# Broadcasting component update (e.g., multiple choice selection)
ConversationChannel.broadcast_to(conversation, {
  type: 'message_update',
  message_id: message.id,
  changes: { components: message.components }
})
```

---

## Flow Summary

### Existing Conversation (Direct URL)
```
1. User navigates to /conversations/:id
2. Client: GET /conversations/:id
3. Client: api.loadMessages(response.messages)  // Instant render
4. Client: Subscribe to ConversationChannel
5. Future updates arrive via WebSocket
```

### New Conversation (Demo/Generate)
```
1. User lands on /
2. Client: POST /conversations/generate
3. Client: Navigate to /conversations/:id
4. Client: Subscribe to ConversationChannel
5. Server streams messages via ActionCable (with typing indicators)
6. Client: api.addMessage() for each incoming message
```

### User Sends Message
```
1. Client: POST /conversations/:id/messages
2. Server: Creates message, assigns sequence
3. Server: Broadcasts to ConversationChannel
4. All clients (including sender): Receive via WebSocket, call api.addMessage()
```

---

## Summary

**Minimal schema (2 tables):**
- `conversations` - container
- `messages` - with inline `author`, `components`, and `reactions` as JSONB

**Thread model**: No separate thread table. Just `parent_message_id` on messages.

**Ordering**: Global monotonic integer `sequence`, enforced by DB lock. Dead simple.

**Edited detection**: `updated_at != created_at` means edited.

**Multiple choice**: Selection stored inline on the component (`selected_option_id`).

**Reactions**: Pre-baked inline on messages. No user interaction.