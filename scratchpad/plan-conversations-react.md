# Plan: Extract Conversation to Reusable React Component

## Requirements (Simplified)

1. **Topics only** - No category/topic hierarchy, just 6 topics with direct links
2. **Conversation UUID routing** - `invariant.training/conversations/:uuid` for bookmarkable links
3. **Dark mode** - Support existing toggle, no other theme variants
4. **Clean async interface** - Design frontend to accept messages via clean JS API
5. **Hardcoded demo on load** - Use lightweight onload callback to stream demo content

---

## Target Architecture

### URL Structure
```
/conversations/:uuid  → Load specific conversation (bookmarkable)
/                     → Landing page with topic nav, default conversation
```

### Component Hierarchy
```
<ConversationApp>
  ├── <TopicNav />           # 6 topic buttons, styled navy bar
  └── <Conversation />       # The chat container
      ├── <MessageList />    # Scrolling messages
      │   └── <Message />    # Individual message (text, code, multiple choice)
      ├── <TypingIndicator />
      └── <MessageInput />   # Text input + send
```

### Core Hook: `useConversation`

```typescript
interface Message {
  id: string;
  content: string;
  author: { name: string; avatar?: string };
  timestamp: Date;
  isSystem: boolean;  // invariant.training vs user
  type?: 'text' | 'code' | 'multiple_choice' | 'loading';
  metadata?: Record<string, any>;
}

interface ConversationAPI {
  messages: Message[];
  isTyping: boolean;
  isConnected: boolean;
  
  // Methods callable from outside React (for demo streaming)
  addMessage: (msg: Partial<Message>) => void;
  setTyping: (typing: boolean) => void;
  sendUserMessage: (content: string) => Promise<void>;
  clear: () => void;
}
```

### Global API for Demo Streaming

Expose a clean interface for non-React code to push messages:

```javascript
// On page load, this becomes available
window.ReplicateConversation = {
  addMessage(msg) { /* dispatches to React state */ },
  setTyping(bool) { /* shows/hides indicator */ },
  onReady(callback) { /* fires when component mounted */ },
};

// Demo usage in onload script:
window.ReplicateConversation.onReady(() => {
  const api = window.ReplicateConversation;
  
  api.setTyping(true);
  setTimeout(() => {
    api.addMessage({
      content: "[SEV-1] DNS resolution failures across prod-east",
      author: { name: "pagerduty", avatar: "/path/to/avatar.png" },
      isSystem: true,
    });
    api.setTyping(false);
  }, 1000);
  
  // Continue streaming demo...
});
```

---

## File Structure

```
app/javascript/
├── components/
│   ├── ConversationApp.jsx    # Root component, handles routing
│   ├── TopicNav.jsx           # Navy bar with 6 topics
│   ├── Conversation.jsx       # Chat container
│   ├── MessageList.jsx        # Renders messages
│   ├── Message.jsx            # Single message (handles all types)
│   ├── TypingIndicator.jsx    # Animated dots
│   └── MessageInput.jsx       # Text input + dropdown
├── hooks/
│   └── useConversation.js     # State + ActionCable
└── entrypoints/
    └── conversations.js       # Mount point, exposes global API
```

---

## Implementation Steps

### Phase 1: Core Components
1. Create `useConversation` hook with clean state management
2. Create `Conversation` component (messages + input)
3. Create `Message` component (supports text, code blocks, multiple choice)
4. Create `TypingIndicator` component
5. Create `MessageInput` with topic dropdown

### Phase 2: Routing & Navigation
1. Add route: `GET /conversations/:uuid` → renders React app
2. Create `TopicNav` component (styled navy bar)
3. Wire up React Router for internal navigation

### Phase 3: Global API
1. Expose `window.ReplicateConversation` interface
2. Create demo streaming script for page load
3. Test with hardcoded DNS incident content

### Phase 4: ActionCable Integration
1. Connect to `ConversationChannel` when UUID present
2. Handle incoming messages from backend
3. Send user messages via POST + ActionCable broadcast

---

## ActionCable Contract

```javascript
// Incoming from server
{
  type: 'message',
  message: {
    id: 'uuid',
    content: 'text or HTML',
    author: { name: 'maya', avatar: '...' },
    is_system: false,
    message_type: 'text' | 'code' | 'multiple_choice',
  }
}

{
  type: 'typing',
  typing: true | false
}

// Outgoing to server (via fetch POST)
POST /conversations/:uuid/messages
{
  content: "user's message"
}
```

---

## Dark Mode Support

Use existing Tailwind dark mode classes. Component will read `dark:` variants automatically when user toggles theme. No special handling needed beyond using proper Tailwind classes:

```jsx
<div className="bg-white dark:bg-gray-900">
  <p className="text-gray-900 dark:text-gray-100">...</p>
</div>
```

---

## Multi-Subscription Architecture

Users can subscribe to multiple conversations over a single WebSocket connection. When they navigate away from a conversation, they stay subscribed and can receive notifications.

### Subscription Manager

```javascript
// Single manager handles all conversation subscriptions
window.ConversationManager = {
  subscriptions: Map<conversationId, { subscription, callbacks }>,
  activeConversationId: string | null,
  
  subscribe(conversationId, callbacks),  // Add subscription
  unsubscribe(conversationId),           // Remove subscription
  setActive(conversationId),             // Mark as currently visible
  
  // Background notifications
  onBackgroundMessage(conversationId, message),
};
```

### ActionCable Contract (Multi-Subscription)

```javascript
// Subscribe to multiple conversations - reuses same WebSocket
consumer.subscriptions.create(
  { channel: 'ConversationChannel', id: conversationId },
  { received, connected, disconnected }
)

// Incoming events include conversation_id for routing
{
  type: 'message',
  conversation_id: 'uuid',
  message: { ... }
}
```

### Notification Flow

1. User opens conversation A → subscribed
2. User navigates to conversation B → subscribed (A still active)
3. Backend sends message to A → Manager routes to A's callbacks
4. If A is background → show toast notification
5. User clicks notification → navigate back to A

---

## Next Actions

1. [x] Create plan document
2. [x] Create `useConversation` hook
3. [x] Create `Conversation` component
4. [x] Create `Message` component  
5. [x] Create `TypingIndicator` component
6. [x] Create `MessageInput` component
7. [x] Create `TopicNav` component
8. [x] Create `ConversationApp` root component
9. [x] Add Rails route for `/conversations/:uuid` (via HashRouter)
10. [x] Expose global API for demo streaming
11. [x] Create demo script with DNS incident content
12. [x] Create `ConversationManager` for multi-subscriptions
13. [x] Wire up ActionCable with subscription manager
14. [x] Add background notification support