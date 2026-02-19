# Conversation System Wiring Plan

## Overview

This document outlines the architecture for the conversation system, including context management, API design, and component responsibilities.

---

## ✅ DONE: Context Created

`ConversationContext.jsx` has been created at:
```
app/javascript/components/conversation/ConversationContext.jsx
```

It implements the full context shape below with:
- `ConversationProvider` component
- `useConversationContext()` hook
- `useConversationByUuid(uuid)` helper hook
- localStorage persistence for UI preferences
- All API methods (fetch, send, markAsRead)
- Local mutation methods for demos (addMessageLocally, updateMessageLocally, setConversationsDirect)

---

## ✅ DONE: Wired Up

### ✅ 1. Wrap ConversationApp with Provider
```jsx
// ConversationApp.jsx - DONE
<ConversationProvider initialConversations={DEMO_CHANNELS}>
  <BrowserRouter>...</BrowserRouter>
</ConversationProvider>
```

### ✅ 2. Update ChannelSwitcher
- Now supports both `uuid` and `id` fields for backward compatibility
- Header displays use `(c.uuid || c.id)` for lookups

### 🔲 3. Update ChannelSwitcher → Use Context Directly (Optional)
- Currently still receives props from ConversationAppInner
- Could import `useConversationContext()` directly to eliminate prop drilling
- Low priority - works fine with current approach

### ✅ 4. Convert DEMO_CHANNELS to new shape
- Added `uuid` field to each channel (using id value for demo)
- Updated comments to document context shape

### ✅ 5. Export from index.js
```js
export { ConversationProvider, useConversationContext, useConversationByUuid } from './ConversationContext'
```

---

## 🔲 TODO: Next Steps

### ✅ 1. Use context for dark mode / sidebar collapsed
- ChannelSwitcher now gets `isDarkMode` / `setIsDarkMode` from context
- Falls back to local state when context unavailable (standalone usage)
- Context syncs to DOM and localStorage

### 2. Build Rails API endpoints
- `Api::ConversationsController` with index, show, update
- `Api::MessagesController` with create
- Connect frontend to real API instead of demo data

### 3. Add ActionCable subscription
- Subscribe to `OwnerChannel` in ConversationProvider
- Handle `new_message`, `unread_update`, `new_conversation` events

---

## Context Shape

All shared state lives in a single `ConversationContext`:

```javascript
{
  // Owner - could be logged-in user or anonymous session
  currentOwner: {
    type: 'User' | 'Session',
    id: string,
    name?: string,
    avatar?: string,
    email?: string,
  },
  
  // Conversations
  conversations: [
    {
      uuid: '550e8400-e5b9-41d4-a716-446655440000',  // Real UUID, used in URLs
      name: 'inc-3815-db-locks',                     // Display name (can repeat across users)
      section: 'incidents',                          // For grouping in sidebar
      unreadCount: 3,
      lastReadMessageId: '7c9e6679-7425-40de-944b-e07fc1f90ae7',
      isMuted: false,
      isPrivate: false,
      
      // Messages - fetched async, nested on conversation object
      messages: [],
      messagesLoading: 'idle',  // 'idle' | 'loading' | 'partial' | 'complete'
    }
  ],
  
  // Actions
  markAsRead: (conversationUuid) => void,
  fetchConversation: (conversationUuid) => Promise<void>,
  sendMessage: (conversationUuid, content) => Promise<Message>,
  
  // UI Preferences (synced to localStorage)
  isDarkMode: boolean,
  setIsDarkMode: (value) => void,
  sidebarCollapsed: boolean,
  setSidebarCollapsed: (value) => void,
}
```

### Key Decisions

1. **UUID for conversations** - Display name (`inc-3815-db-locks`) can repeat across users. UUID is the real identifier used in URLs and API calls.

2. **Messages nested on conversation** - No parallel hashes like `messagesByConversation` and `messagesLoadingState`. Everything about a conversation lives on the conversation object itself.

3. **Loading states**:
   - `idle` - Haven't fetched yet
   - `loading` - Currently fetching
   - `partial` - Have some messages, more available (for pagination)
   - `complete` - Have all messages

4. **`activeConversationId` comes from URL** - Via `useParams()`, not stored in context. This makes URLs shareable and lets the router be the source of truth.

---

## Owner Model

Conversations have polymorphic `owner_type` and `owner_id` fields:

```ruby
# Conversation model
belongs_to :owner, polymorphic: true  # owner_type: 'User' | 'Session', owner_id: string
```

- **Anonymous visitors** - `owner_type: 'Session'`, `owner_id: session[:identifier]`
- **Logged-in users** - `owner_type: 'User'`, `owner_id: user.id`
- **On login** - Session-owned conversations get transferred: `Conversation.transfer_session_to_user(session_id, user)`

The frontend doesn't care about owner. It just calls the API - Rails scopes queries by the polymorphic owner fields.

---

## API Design

Standard RESTful Rails routes:

```
GET    /api/conversations              # index - list all conversations for current owner
GET    /api/conversations/:uuid        # show - get conversation with messages
PATCH  /api/conversations/:uuid        # update - mark as read, mute, etc.
POST   /api/conversations/:uuid/messages  # create message
```

### Rails Controller

```ruby
# config/routes.rb
namespace :api do
  resources :conversations, only: [:index, :show, :update] do
    resources :messages, only: [:create]
  end
end

# app/controllers/api/conversations_controller.rb
class Api::ConversationsController < ApplicationController
  def index
    render json: conversations_for_current_owner
  end

  def show
    conversation = find_conversation(params[:id])
    render json: conversation.as_json(include: :messages)
  end

  def update
    conversation = find_conversation(params[:id])
    conversation.update!(conversation_params)
    render json: conversation
  end

  private

  def find_conversation(uuid)
    # Finds conversation by UUID for current owner (User or Session)
  end

  def conversation_params
    params.permit(:last_read_message_id, :muted)
  end
end
```

### Frontend API Layer

```javascript
// api/conversations.js

export const getConversations = () =>
  fetch('/api/conversations', { credentials: 'include' })
    .then(r => r.json())

export const getConversation = (uuid) =>
  fetch(`/api/conversations/${uuid}`, { credentials: 'include' })
    .then(r => r.json())

export const updateConversation = (uuid, params) =>
  fetch(`/api/conversations/${uuid}`, {
    method: 'PATCH',
    credentials: 'include',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(params),
  }).then(r => r.json())

export const createMessage = (conversationUuid, content) =>
  fetch(`/api/conversations/${conversationUuid}/messages`, {
    method: 'POST',
    credentials: 'include',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ content }),
  }).then(r => r.json())
```

---

## Data Flow

### Page Load

```
1. User lands on page
2. ConversationProvider mounts
3. Calls GET /api/conversations
4. Rails checks session → returns conversations for User or Session owner
5. Context populated with conversation metadata (no messages yet)
6. User navigates to /conversations/:uuid
7. Conversation component mounts → calls fetchConversation(uuid)
8. GET /api/conversations/:uuid returns conversation with messages
9. Context updated with messages, messagesLoading → 'complete'
```

### Mark as Read

```
1. User clicks on conversation in sidebar
2. Router navigates to /conversations/:uuid
3. On mount (or channel select), call markAsRead(uuid)
4. Optimistic update: set unreadCount → 0 immediately
5. PATCH /api/conversations/:uuid { last_read_message_id: 'msg-xxx' }
6. Server persists, responds with updated conversation
```

No delay on mark-as-read. If they clicked it, they're reading it.

### Send Message

```
1. User types message, hits enter
2. Disable input, show loading indicator
3. POST /api/conversations/:uuid/messages { content: '...' }
4. Server creates message, responds with created message
5. Append message to local state
6. Hide loading indicator, re-enable input, clear input
7. If error: show error toast, hide loading indicator, re-enable input (message stays in input for retry)
```

---

## Demo Data Seeding

Seed demo conversations to a session so you can navigate and test the UI.

### Rake Task

```ruby
# lib/tasks/demo.rake

namespace :demo do
  desc "Seed demo conversations for a session"
  task :seed, [:session_id] => :environment do |t, args|
    session_id = args[:session_id] || SecureRandom.hex(10)
    
    # Create or find the session
    session = Session.find_or_create_by!(id: session_id)
    
    # Seed conversations
    conversations = [
      { name: 'inc-3815-db-locks', section: 'incidents' },
      { name: 'inc-3824-redis-oom', section: 'incidents' },
      { name: 'inc-3819-api-latency', section: 'incidents' },
      { name: 'ops-alerts', section: 'ops' },
      { name: 'oncall', section: 'ops' },
      { name: 'oncall-leads', section: 'ops', is_private: true },
      { name: 'deploy-prod', section: 'ops' },
      { name: 'deploy-staging', section: 'ops', is_muted: true },
      { name: 'platform-eng', section: 'teams' },
      { name: 'backend', section: 'teams' },
      { name: 'frontend', section: 'teams' },
      { name: 'infra', section: 'teams' },
      { name: 'sre-team', section: 'teams' },
      { name: 'security', section: 'teams' },
      { name: 'security-incidents', section: 'teams', is_private: true },
      { name: 'engineering', section: 'general' },
      { name: 'random', section: 'general', is_muted: true },
      { name: 'watercooler', section: 'general' },
      { name: 'maya', section: 'dms' },
      { name: 'alex', section: 'dms' },
      { name: 'daniel', section: 'dms' },
      { name: 'sarah', section: 'dms' },
      { name: 'chen', section: 'dms' },
      { name: 'priya', section: 'dms' },
    ]
    
    conversations.each do |attrs|
      Conversation.find_or_create_by!(
        owner_type: 'Session',
        owner_id: session_id,
        name: attrs[:name]
      ) do |c|
        c.section = attrs[:section]
        c.is_private = attrs[:is_private] || false
        c.is_muted = attrs[:is_muted] || false
      end
    end
    
    puts "Seeded #{conversations.length} conversations for session: #{session_id}"
    puts "Set your session cookie to this ID to use them"
  end
end
```

### Usage

```bash
# Generate a new session with demo data
rails demo:seed

# Seed to a specific session ID
rails demo:seed[abc123def456]
```

### Navigating as the Session

Set `session[:identifier]` in your browser to the seeded session ID. The API will return those conversations.

For local dev, add a route to set the session:

```ruby
# config/routes.rb (development only)
if Rails.env.development?
  get '/dev/session/:id', to: 'dev#set_session'
end

# app/controllers/dev_controller.rb
class DevController < ApplicationController
  def set_session
    session[:identifier] = params[:id]
    redirect_to root_path, notice: "Session set to #{params[:id]}"
  end
end
```

Then visit `/dev/session/abc123def456` to become that session.

---

## Component Architecture

### Provider Hierarchy

```
<ConversationProvider>        ← owns conversations[], messages, UI preferences
  <Router>
    <ConversationSidebar>     ← consumes context, renders sidebar
      <Conversation>          ← consumes context, renders messages, calls sendMessage
    </ConversationSidebar>
  </Router>
</ConversationProvider>
```

### ConversationSidebar (currently ChannelSwitcher)

**Responsibilities:**
- Render sidebar with conversation list grouped by section
- Render header bar with conversation name
- Handle sidebar collapse/expand
- Handle dark mode toggle
- Handle mobile menu

**Gets from context:**
- `conversations`
- `isDarkMode`, `setIsDarkMode`
- `sidebarCollapsed`, `setSidebarCollapsed`

**Gets from router:**
- `activeConversationId` via `useParams()`

**No longer receives as props:**
- ~~`channels`~~
- ~~`activeChannelId`~~
- ~~`onChannelSelect`~~

### Conversation

**Responsibilities:**
- Fetch messages on mount (if not already loaded)
- Render message list
- Handle message input/send
- Call markAsRead on mount

**Gets from context:**
- `conversations` (to find current one by UUID)
- `fetchConversation(uuid)`
- `sendMessage(uuid, content)`
- `markAsRead(uuid)`

**Gets from router:**
- `uuid` via `useParams()`

---

## Naming Conventions

The system is **conversations**, not channels:

| Current | Should Be |
|---------|-----------|
| `ChannelSwitcher` | `ConversationSidebar` or `SidebarLayout` |
| `ChannelItem` | `ConversationItem` |
| `ChannelSection` | `ConversationSection` |
| `ChannelList` | `ConversationList` |
| `channels` prop | `conversations` |
| `activeChannelId` | `activeConversationId` |
| `onChannelSelect` | `onConversationSelect` |
| `channelData.js` | `conversationData.js` |

A "channel" implies a Slack-style persistent room. What we have is **conversations** - which could be incidents, team discussions, or DMs. They're all conversations.

---

## URL Structure

```
/conversations/:uuid
```

Example:
```
/conversations/550e8400-e5b9-41d4-a716-446655440000
```

Display shows the name (`#inc-3815-db-locks`), but URL uses UUID. Two users can both have a conversation named `#inc-3815-db-locks` but they're different UUIDs pointing to different message histories.

---

## UI Preferences in Context

Currently scattered as local state in `ChannelSwitcher`. Should live in context:

```javascript
// In ConversationProvider
const [isDarkMode, setIsDarkMode] = useState(() => {
  return localStorage.getItem('theme') === 'dark' || 
    document.documentElement.classList.contains('dark')
})

const [sidebarCollapsed, setSidebarCollapsed] = useState(() => {
  return localStorage.getItem('sidebar-collapsed') === 'true'
})

// Sync to localStorage on change
useEffect(() => {
  localStorage.setItem('theme', isDarkMode ? 'dark' : 'light')
  if (isDarkMode) {
    document.documentElement.classList.add('dark')
  } else {
    document.documentElement.classList.remove('dark')
  }
}, [isDarkMode])

useEffect(() => {
  localStorage.setItem('sidebar-collapsed', sidebarCollapsed)
}, [sidebarCollapsed])
```

This way:
- They persist across page loads (localStorage)
- They're accessible anywhere (e.g., settings modal could toggle dark mode)
- Single source of truth

---

## Implementation Order

1. **Create `ConversationContext` and `ConversationProvider`**
   - Move UI preferences from `ChannelSwitcher` local state to context
   - Add conversations state with loading states
   - Add action functions (markAsRead, fetchConversation, sendMessage)

2. **Create API layer** (`api/conversations.js`)
   - getConversations, getConversation, updateConversation, createMessage

3. **Rename components**
   - `ChannelSwitcher` → `ConversationSidebar`
   - Update all `channel` references to `conversation`
   - Update demo data file

4. **Wire up context**
   - `ConversationSidebar` consumes context instead of props
   - `Conversation` consumes context for messages and actions

5. **Build Rails API endpoints**
   - `Api::ConversationsController` with index, show, update
   - `Api::MessagesController` with create
   - Handle demo data for training users

6. **Update routing**
   - URLs use UUID: `/conversations/:uuid`

---

## Sessions Table Cleanup

The `sessions` table is legacy cruft from analytics tracking. Keep the table name (it's good), but gut the columns.

### Current Schema (legacy)

```sql
CREATE TABLE public.sessions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    ip character varying,              -- DELETE
    page character varying,            -- DELETE
    referring_page character varying,  -- DELETE
    duration integer,                  -- DELETE
    created_at timestamp(6),
    updated_at timestamp(6),
    user_agent text                    -- DELETE
);
```

### New Schema

```sql
CREATE TABLE public.sessions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);
```

That's it. Just an ID and timestamps. The session ID is stored in the Rails session cookie (`session[:identifier]`) and used as `owner_id` on conversations when `owner_type = 'Session'`.

### Migration

```ruby
class CleanupSessionsTable < ActiveRecord::Migration[7.0]
  def change
    remove_column :sessions, :ip, :string
    remove_column :sessions, :page, :string
    remove_column :sessions, :referring_page, :string
    remove_column :sessions, :duration, :integer
    remove_column :sessions, :user_agent, :text
  end
end
```

### Also Delete

- `SessionsController#pulse` - the old analytics endpoint that populated this junk
- Any references to session tracking in the frontend

---

## ActionCable

One channel per session. The session ID is the stable identifier - it doesn't change when they log in.

### Why Session ID, Not User ID

- **Multiple tabs work** - All tabs share the same session, same channel
- **No reconnect on login** - Channel stays connected when user logs in
- **Transfer is just data** - When user logs in, conversations transfer from Session owner to User owner, but the ActionCable channel stays the same
- **Simple** - One identifier throughout the session lifecycle

### OwnerChannel

```ruby
# app/channels/owner_channel.rb
class OwnerChannel < ApplicationCable::Channel
  def subscribed
    session_id = params[:session_id]
    if session_id.present?
      stream_for "session:#{session_id}"
    else
      reject
    end
  end
end
```

The frontend passes `session_id` when subscribing. This is the same `session[:identifier]` from the Rails session cookie.

### Broadcasting

Always broadcast to the session, not the user:

```ruby
# Helper method
def broadcast_to_session(session_id, payload)
  OwnerChannel.broadcast_to("session:#{session_id}", payload)
end

# After creating a message
broadcast_to_session(conversation.session_id, {
  type: 'new_message',
  conversation_uuid: conversation.id,
  message: message.as_json
})
```

### What Gets Broadcast

- `new_message` - New message in any conversation
- `unread_update` - Unread count changed for a conversation
- `new_conversation` - A new conversation was created

### Frontend Subscription

Subscribe once on page load with the session ID:

```javascript
// In ConversationProvider
useEffect(() => {
  const sessionId = getSessionId() // From cookie or meta tag
  
  const subscription = cable.subscriptions.create(
    { channel: 'OwnerChannel', session_id: sessionId },
    {
      received(data) {
        switch (data.type) {
          case 'new_message':
            handleNewMessage(data.conversation_uuid, data.message)
            break
          case 'unread_update':
            handleUnreadUpdate(data.conversation_uuid, data.unread_count)
            break
          case 'new_conversation':
            handleNewConversation(data.conversation)
            break
        }
      }
    }
  )
  
  return () => subscription.unsubscribe()
}, [])
```

### Context Handlers

```javascript
const handleNewMessage = (conversationUuid, message) => {
  setConversations(prev => prev.map(c => {
    if (c.uuid !== conversationUuid) return c
    
    // Append message if we have messages loaded
    if (c.messagesLoading === 'complete' || c.messagesLoading === 'partial') {
      return { ...c, messages: [...c.messages, message] }
    }
    return c
  }))
}

const handleUnreadUpdate = (conversationUuid, unreadCount) => {
  setConversations(prev => prev.map(c =>
    c.uuid === conversationUuid ? { ...c, unreadCount } : c
  ))
}

const handleNewConversation = (conversation) => {
  setConversations(prev => [...prev, {
    ...conversation,
    messages: [],
    messagesLoading: 'idle'
  }])
}
```

### When to Broadcast

**After message creation (in controller or worker):**
```ruby
# After creating a message
message = conversation.messages.create!(...)

# Get the session ID for this conversation's owner
# (Conversation stores session_id regardless of whether owner is User or Session)
session_id = conversation.session_id

broadcast_to_session(session_id, {
  type: 'new_message',
  conversation_uuid: conversation.id,
  message: message.as_json
})

# Also send unread update if not currently viewing
broadcast_to_session(session_id, {
  type: 'unread_update', 
  conversation_uuid: conversation.id,
  unread_count: conversation.unread_count
})
```

---

## ConversationDriverWorker (Bot Responses)

The `ConversationDriverWorker` is the Sidekiq worker that generates bot/AI responses in conversations.

### When It Runs

1. **User sends a message** - `Message.after_create` triggers the worker if `user_generated: true`
2. **User opens empty conversation** - `OwnerChannel.subscribed` can trigger it for a fresh conversation

### Flow

```
User sends message
  → Message.create!(user_generated: true)
  → after_create callback
  → ConversationDriverWorker.perform_async(conversation_id, min_sequence)
  → Worker picks up job
  → MessageGenerators::Incident (or variant).deliver
  → Generator creates messages + broadcasts via ActionCable
  → Frontend receives via OwnerChannel → handleNewMessage
```

### MessageGenerators

Each conversation has a `variant` field that determines which generator to use:

```ruby
# conversation.variant = 'incident'
generator = "MessageGenerators::#{conversation.variant.camelize}".constantize
# → MessageGenerators::Incident
```

Generators are responsible for:
- Creating `Message` records
- Broadcasting to ActionCable (so UI updates in real-time)
- Simulating typing delays, multi-message sequences, etc.

### Broadcasting from Workers

Workers use `broadcast_to_owner` to send messages to all active sessions:

```ruby
# In MessageGenerators::Base or similar
def broadcast_to_web(payload)
  broadcast_to_owner({
    type: 'new_message',
    conversation_uuid: conversation.id,
    message: payload
  })
end

def broadcast_to_owner(payload)
  sessions = conversation.user&.sessions&.active || [conversation.session]
  sessions.each do |session|
    OwnerChannel.broadcast_to("session:#{session.id}", payload)
  end
end
```

### Sequence Numbers

Messages have a `sequence` field for ordering. The worker receives `min_sequence` to know where to start generating from (avoids race conditions with multiple messages being created).

### Guard Against Double-Responses

```ruby
def perform(conversation_id, min_sequence = nil)
  conversation = Conversation.find_by(id: conversation_id)
  return if conversation.blank?
  return if conversation.latest_author == :assistant  # Already responded
  
  # Generate response...
end
```

If the last message was already from the assistant, the worker exits early. Prevents duplicate bot responses.

---