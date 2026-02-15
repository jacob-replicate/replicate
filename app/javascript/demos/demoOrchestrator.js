/**
 * Demo Orchestrator - handles fake conversation flow after user selects an option
 *
 * Hardcoded paths based on the 4 multiple choice options:
 * a) SKIP LOCKED - decent suggestion, gets mild pushback then follow-up
 * b) Distributed lock (Redis/ZK) - overkill, engineers push back
 * c) Job queue (correct) - engineers engage, deeper question follows
 * d) Increase pool size - wrong, engineers correctly push back hard
 */

const sleep = (ms) => new Promise(resolve => setTimeout(resolve, ms))

// Engineers in the incident
const ENGINEERS = {
  daniel: { name: 'daniel', avatar: '/profile-photo-2.jpg' },
  maya: { name: 'maya', avatar: '/profile-photo-3.jpg' },
  alex: { name: 'alex', avatar: '/profile-photo-1.jpg' },
}


/**
 * Response paths for each option
 */
const RESPONSE_PATHS = {
  // Option A: SKIP LOCKED - decent but incomplete
  'a': {
    responses: [
      {
        author: ENGINEERS.daniel,
        delay: 1200,
        content: "SKIP LOCKED helps with the blocking but doesn't actually prevent double-processing — two workers can still grab different rows for the same logical order if the data is split across tables",
      },
      {
        author: ENGINEERS.maya,
        delay: 2000,
        content: "yeah and we'd still have the connection exhaustion issue under high load. SKIP LOCKED is a bandaid",
      },
    ],
    followUp: {
      delay: 1500,
      question: "Daniel's right — SKIP LOCKED prevents blocking but not duplication. What's the actual invariant you need to enforce here?",
      options: [
        {
          id: 'a1',
          thought: 'Each order should only be processed by one worker at a time',
          message: "the invariant is one worker per order at a time — we need exclusive access during processing",
        },
        {
          id: 'a2',
          thought: 'Each order should only be processed exactly once, ever',
          message: "actually the real invariant is exactly-once processing. even if we fix the locking, retries could still double-process",
        },
      ],
    },
    finalResponse: {
      author: ENGINEERS.maya,
      delay: 1800,
      content: "exactly. the row lock was trying to solve coordination at the wrong layer. we need idempotency keys or a proper queue with deduplication",
    },
  },

  // Option B: Distributed lock - overkill
  'b': {
    responses: [
      {
        author: ENGINEERS.alex,
        delay: 1000,
        content: "Redis for this? that's a lot of operational overhead for something we could solve with better SQL",
      },
      {
        author: ENGINEERS.daniel,
        delay: 1800,
        content: "plus now we have a new failure mode — what happens when Redis is down? we'd need to handle lock acquisition failures gracefully",
      },
      {
        author: ENGINEERS.maya,
        delay: 1400,
        content: "I've seen teams add Redis locks and then spend 6 months debugging clock skew and lock expiration edge cases. let's not",
      },
    ],
    followUp: {
      delay: 1500,
      question: "The team is pushing back on operational complexity. When is a distributed lock actually the right call vs. solving it at the application layer?",
      options: [
        {
          id: 'b1',
          thought: 'When you need coordination across multiple services or databases',
          message: "fair — distributed locks make sense when you're coordinating across service boundaries. single database? probably not worth it",
        },
        {
          id: 'b2',
          thought: 'When the lock duration is short and predictable',
          message: "you're right, the failure modes are tricky. Redis locks work when lock duration is predictable and short. our query times are all over the place",
        },
      ],
    },
    finalResponse: {
      author: ENGINEERS.daniel,
      delay: 1600,
      content: "yeah let's keep it simple. SQS FIFO with message deduplication handles this without us managing lock infrastructure",
    },
  },

  // Option C: Job queue (correct answer) - engineers engage positively
  'c': {
    responses: [
      {
        author: ENGINEERS.daniel,
        delay: 1200,
        content: "+1, this is the right layer to solve it. SQS FIFO with deduplication would give us exactly-once semantics without the lock complexity",
      },
      {
        author: ENGINEERS.alex,
        delay: 1600,
        content: "we'd need to change how orders get enqueued though. right now the API writes to the DB and workers poll. moving to push-based is a bigger migration",
      },
    ],
    followUp: {
      delay: 1500,
      question: "Alex raises a real concern — migrating to a queue is the right long-term fix but it's not a quick change. How do you sequence this?",
      options: [
        {
          id: 'c1',
          thought: 'Ship idempotency keys now, migrate to queue later',
          message: "short term: add idempotency keys to the order processing so retries are safe. then we can migrate to SQS without time pressure",
        },
        {
          id: 'c2',
          thought: 'Dual-write during migration, then cut over',
          message: "we can dual-write during migration — keep the DB polling but also enqueue to SQS. once we verify SQS is reliable, cut over and remove the polling",
        },
      ],
    },
    finalResponse: {
      author: ENGINEERS.maya,
      delay: 1800,
      content: "let's do idempotency keys first. that de-risks the migration and means we're not racing to ship the queue integration",
    },
  },

  // Option D: Increase pool size (wrong answer) - engineers push back hard
  'd': {
    responses: [
      {
        author: ENGINEERS.daniel,
        delay: 800,
        content: "that... won't help? the connections aren't exhausted because we don't have enough — they're exhausted because queries are deadlocked waiting on each other",
      },
      {
        author: ENGINEERS.maya,
        delay: 1400,
        content: "more connections just means more queries waiting on the same locks. we'd hit the same wall at 100 instead of 50",
      },
      {
        author: ENGINEERS.alex,
        delay: 1000,
        content: "also postgres has a max_connections limit, and each connection has memory overhead. can't just keep bumping it",
      },
    ],
    followUp: {
      delay: 1500,
      question: "The team correctly identified this as treating symptoms, not causes. What's the actual bottleneck here?",
      options: [
        {
          id: 'd1',
          thought: 'The FOR UPDATE lock is creating contention',
          message: "you're right, I was thinking about it wrong. the bottleneck is lock contention, not pool size. we need to eliminate the lock or make it non-blocking",
        },
        {
          id: 'd2',
          thought: 'Workers are competing for the same rows',
          message: "the real issue is multiple workers trying to process the same order simultaneously. we need coordination before the query, not during",
        },
      ],
    },
    finalResponse: {
      author: ENGINEERS.daniel,
      delay: 1400,
      content: "right. the database isn't the right place for job coordination. that's what queues are for",
    },
  },
}

/**
 * Orchestrate the demo conversation after user selects an option
 *
 * @param {string} optionId - The selected option (a, b, c, or d)
 * @param {object} api - The ReplicateConversation API
 */
export async function orchestrateDemoResponse(optionId, api) {
  const path = RESPONSE_PATHS[optionId]
  if (!path) {
    console.warn(`[DemoOrchestrator] Unknown option: ${optionId}`)
    return
  }

  const getNextSequence = () => {
    const messages = api.getMessages?.() || []
    return messages.reduce((max, m) => Math.max(max, m.sequence ?? 0), 0) + 1
  }

  // Stream the engineer responses
  for (const response of path.responses) {
    await sleep(response.delay)

    // Show typing indicator
    api.setTyping?.(response.author)
    await sleep(600)
    api.setTyping?.(false)

    // Add the message
    api.addMessage?.({
      id: `msg_${Date.now()}_${Math.random().toString(36).slice(2, 9)}`,
      sequence: getNextSequence(),
      author: response.author,
      created_at: new Date().toISOString(),
      components: [{ type: 'text', content: response.content }],
    })
  }

  // Add follow-up system prompt instantly (no typing indicator, no delay)
  if (path.followUp) {
    api.addMessage?.({
      id: `msg_followup_${Date.now()}`,
      sequence: getNextSequence(),
      created_at: new Date().toISOString(),
      isSystem: true,
      components: [{
        type: 'multiple_choice',
        question: path.followUp.question,
        options: path.followUp.options,
      }],
    })
  }
}

/**
 * Handle second-level option selection (the follow-up question)
 */
export async function orchestrateFollowUpResponse(optionId, api) {
  // Find which path this belongs to
  let finalResponse = null

  for (const [, path] of Object.entries(RESPONSE_PATHS)) {
    const matchingOption = path.followUp?.options?.find(o => o.id === optionId)
    if (matchingOption) {
      finalResponse = path.finalResponse
      break
    }
  }

  if (!finalResponse) {
    console.warn(`[DemoOrchestrator] Unknown follow-up option: ${optionId}`)
    return
  }

  const getNextSequence = () => {
    const messages = api.getMessages?.() || []
    return messages.reduce((max, m) => Math.max(max, m.sequence ?? 0), 0) + 1
  }

  await sleep(finalResponse.delay)

  // Show typing indicator
  api.setTyping?.(finalResponse.author)
  await sleep(600)
  api.setTyping?.(false)

  // Add final response
  api.addMessage?.({
    id: `msg_${Date.now()}_${Math.random().toString(36).slice(2, 9)}`,
    sequence: getNextSequence(),
    author: finalResponse.author,
    created_at: new Date().toISOString(),
    components: [{ type: 'text', content: finalResponse.content }],
  })
}

/**
 * Check if an option is a follow-up (second level) option
 */
export function isFollowUpOption(optionId) {
  for (const [, path] of Object.entries(RESPONSE_PATHS)) {
    if (path.followUp?.options?.some(o => o.id === optionId)) {
      return true
    }
  }
  return false
}

/**
 * Check if an option is a primary (first level) option
 */
export function isPrimaryOption(optionId) {
  return ['a', 'b', 'c', 'd'].includes(optionId)
}