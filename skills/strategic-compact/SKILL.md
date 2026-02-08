---
name: strategic-compact
description: Suggests manual /compact at logical workflow breakpoints to preserve context quality. Prevents arbitrary auto-compaction from losing important state mid-task.
---

# Strategic Compact

Suggest manual `/compact` at logical breakpoints rather than letting auto-compaction happen at arbitrary points in the conversation.

## When to Suggest Compaction

Proactively suggest `/compact` at these natural breakpoints:

### After Exploration, Before Implementation
> "I've finished exploring the codebase and have a plan. This is a good point to `/compact` before we start writing code — it'll preserve the plan while dropping the raw file reads."

### After a Milestone Completes
> "Tests are passing and the feature is working. Good time to `/compact` — we'll keep the current state and free up context for the next task."

### Before a Major Context Shift
> "We're about to switch from the tile system to the UI layer. Suggest `/compact` first so we're not carrying stale tile code context."

### After a Long Debugging Session
> "Found and fixed the bug. The debugging exploration used a lot of context — `/compact` will clean that up while keeping the fix."

### When Context Is Getting Heavy
> "We've been going for a while and I can feel the context getting dense. Good breakpoint to `/compact` before continuing."

## How to Suggest

Keep it brief. One line at the end of a response:

```
Good breakpoint to `/compact` — we've finished [phase] and are about to start [next phase].
```

Don't interrupt flow to suggest it. Mention it naturally when there's a pause between phases.

## Why This Matters

- **Auto-compaction is arbitrary** — it triggers on token count, not workflow state. It might compact mid-implementation, losing important context about what you were building and why.
- **Manual compaction is strategic** — you choose what state to preserve. The compact summary captures the current plan, decisions made, and what's next.
- **Long sessions benefit most** — after 30+ minutes of back-and-forth, the early context is stale. Compacting after milestones keeps the working set relevant.

## What Gets Preserved

When `/compact` runs, the system summarizes:
- Current task and progress
- Key decisions made
- Files modified
- What's left to do

What gets dropped:
- Raw file reads (can re-read as needed)
- Exploration dead ends
- Verbose build output
- Intermediate debugging steps
