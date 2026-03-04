# Invariant — Engineering Notes for Coding Agents (Get Product-Accurate Fast)

This doc is meant to get you shipping **product-aligned code** quickly. It focuses on the *nitty gritty* of how Invariant should feel and behave, not generic "LLM app" advice.

---

## Start Here (Codebase Orientation)

**Chat UI (JSX):**
- `app/javascript/components/conversation/ConversationApp.jsx` — main orchestration, message streaming
- `app/javascript/components/conversation/Conversation.jsx` — chat thread layout
- `app/javascript/components/conversation/MessageInput.jsx` — user input + scaffolding options
- `app/javascript/demos/` — demo scenarios and response orchestration

Backend is not yet refactored to match these patterns.

---

## What Invariant Is

Invariant is a **single-player**, Slack-like incident simulation that trains **production judgment** (infra/reliability first; security later) through **consequence-based** interaction.

Not a course. Not a quiz. Not a checklist. Not "correct/incorrect."
It's a **cognitive gym**: realistic incident → ambiguity → decisions → consequences → mental model sharpening.

---

## Core Product Philosophy (Non-Negotiables)

### 1) Immersion over instruction
- **No system voice.** No "trainer narration."
- The user is *inside* an incident channel with believable teammates/logs/graphs.
- The interface should disappear; the incident should dominate.

### 2) Consequence-based, not correctness-based
- Never say "wrong."
- Respond with realistic outcomes, tradeoffs, side-effects, follow-on failures.
- Reward good thinking by making the system behave better, not by praising.

### 3) Calm operational minimalism
- Serious, restrained UI.
- No gamification.
- No dopamine mechanics.
- Dense enough to feel real.

### 4) Keyboard-first
- Numeric selection should be easy and fast.
- Typing is the end-state; scaffolding fades away.

### 5) Depth over breadth
- We'd rather have fewer invariants with deep, sharp scenarios than a wide shallow catalog.

---

## Interaction Mechanic: Scaffolding Fades (3 → 2 → 0)

The **core loop** is "chat" where early on the user can choose from multiple-choice scaffolds that gradually disappear.

### Progression
- Early: **3 options**
- Then: **2 options**
- Then: **0 options** (user types freely)
- After that: only a subtle **/hint** command will show the MCQ again.

### Critical behavior
- When user selects an option, it becomes a **message authored by the user** in the thread (in-character), not a UI choice confirmation.
- The choices are **scaffolding**, not the canonical interface.
- Scaffolding should feel "temporary" and fade without ceremony.

### Hint behavior
- Hint is subtle.
- Hint should be framed as a teammate nudge, log suggestion, or next diagnostic step, not a tutor tip.
- Hint usage can be tracked (quietly) for insights, but don't shame.

---

## "Invariant" Concept (What We Train)

An **invariant** is: *what must remain true, even under stress, partial failure, and retries.*

Examples (infra-focused initial set):
- Idempotency / retry-safety
- Exactly-once illusions vs at-least-once reality
- Locking and isolation guarantees
- Work distribution and duplication avoidance
- Backpressure, load shedding
- Pool exhaustion and queue collapse
- Causal ordering / race conditions
- Timeouts, cancellation, bounded work
- AuthN/AuthZ invariants
- Replay resistance
- Trust boundaries
- Token lifecycle, revocation, session fixation
- Least privilege in practice

---

## UI / UX Requirements (Slack-like Container)

### Visual
- Dark Slack-adjacent layout (not "hacker edgy"; calm/deliberate).
- Left sidebar contains "exit points" into other invariants / scenarios.
- Dense message layout; code blocks and logs should feel native.
- Avoid "SaaS cards everywhere."

### Behavior
- No fake unread indicators.
- Sidebar activity should feel organic, not gamified.
- Minimal slash commands; keep it conversational.
- Nothing should look like "a course module."

### Accessibility
- High contrast but not neon.
- Keyboard navigation is first-class.

---

## Business Constraints (Product Shape)

### Single-player only (for now)
Do not build multiplayer unless explicitly requested later. It increases surface area and dilutes cognitive strain.

### No calls
The product must be self-serve with async support only. Design UX and docs accordingly.

### Contracts / billing posture (high-level)
- 3-month free trial.
- One annual invoice due 30 days after trial ends.
- ACH/wire.
- Pre-signed MSA/DPA via DocuSign.
- No auto-renew, no evergreen.
- Clear deletion if they do nothing.
- No RFPs/redlines/vendor portals.
- Optional multi-year prepay with 30% discount.

---

## What Not To Build (Anti-Goals)

- XP points, streaks, leaderboards
- Certificates, badges
- "Correct answer" grading UI
- Heavy integrations as defaults (HRIS, LMS, etc.)
- Feature-bloat dashboards that overshadow the gym
- Any "course builder" / content library framing

---

## Quality Bar (What "Good" Looks Like)

A good run produces:
- a transcript that reads like a real incident
- at least one "wince" moment for experienced engineers
- clear cognitive strain (tradeoffs, uncertainty, consequences)
- a changed mental model ("oh, that invariant is what I violated")

If something is "pleasant" but not "sharp," it's wrong.