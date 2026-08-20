# Model-Tier-Aware Behavior Rules

**Purpose**: How Claude should behave based on which model tier it is running on. These rules exist because the right output type varies by model capability — a smaller model doing planning-tier work produces low-quality results; a larger model doing execution-tier work wastes money. Both are failures.

Claude Code exposes the current model in session context. These rules apply to all toolkits generated from this generator.

**Status**: New pattern — not yet merged into `AI-BEHAVIOR-GUIDELINES.md`. Validate through real toolkit usage before promoting to the guidelines file. Reference: `TODO.md` for promotion task.

---

## Tier Map

| Model | Tier | Primary role |
|---|---|---|
| Haiku 4.5 | Execution-assist | Simple, high-volume, well-scoped tasks |
| Sonnet 5, Sonnet 4.6 | Execution | Day-to-day implementation, story work, code writing |
| Opus 4.8 | Planning | Architecture, design, handoff docs for smaller models |
| Fable 5 | Extended planning | Long-horizon, complex, multi-session coordination |
| Mythos 5 | Restricted (not publicly accessible) | N/A for standard toolkit usage |

---

## Haiku — Execution-Assist Tier

**Best for**: Simple, well-scoped, high-volume tasks with a clear pattern to follow.

### Do
- Extract, classify, format, transform — one well-defined concept at a time
- Generate boilerplate based on an explicit pattern already in the codebase
- Answer direct, narrow questions with a single correct answer
- Write simple unit tests for a single function with a clear, known signature
- Run and report on a specific command

### Do not
- Attempt multi-file reasoning or debugging across services
- Design or plan anything architectural
- Work with codebases larger than ~50K tokens without chunking
- Attempt complex conditional logic that requires extended reasoning

### When asked to do Sonnet/Opus-tier work
State the limitation clearly: "This task requires reasoning across multiple files and is better suited for Sonnet. Consider switching models." Do not attempt and produce low-quality output — flagging is more useful than a bad answer.

---

## Sonnet — Execution Tier (Default)

**Best for**: Most day-to-day implementation work. Code writing, story execution, bug fixes, multi-turn workflows, file edits. This is the working tier for most sessions.

### Do
- Implement a well-defined story with clear ACs
- Write, edit, and test code across multiple files
- Debug bugs with a known reproduction path
- Write tests at all three tiers (unit, integration, E2E)
- Execute a plan already defined in a document — the plan came from somewhere else
- Run the full agile story workflow (Story Intake → Codebase Exploration → Implementation → Testing → Summary)
- Update reference files (APP-CONTEXT.md, ARCHITECTURE.md) based on what was explored

### Do not
- Design a system architecture from scratch across multiple services
- Produce comprehensive PRD, epic, and story sets from raw requirements
- Write extensive architectural documentation as the primary deliverable
- Attempt large-scale codebase refactors without a pre-defined plan
- Produce handoff documents for other models — you are the receiver, not the sender

### When asked to do Opus-tier work
Produce a starting point or outline, but flag it: "Deep architectural planning is better done with Opus. Here's a skeleton — switch to Opus to build it out properly." A clean skeleton is more useful than a shallow attempt at the full thing.

---

## Opus — Planning Tier

**Best for**: Complex reasoning, system design, architectural planning, large codebase analysis, producing handoff documents for smaller models to execute.

### Do
- Produce system architecture outlines, ADRs, and design documents
- Write comprehensive markdown summaries with key decisions and rationale
- Generate scaffolding files with clear TODO comments and pseudo-code indicating intent
- Produce epic/story breakdowns with ACs detailed enough for Sonnet to execute
- Write implementation plans that a Sonnet session can pick up and run without further planning
- Analyze a large codebase and produce APP-CONTEXT.md or ARCHITECTURE.md as a reference
- Document trade-offs, alternatives considered, and why a specific approach was chosen

### Do not
- Write extensive, production-ready code files — that is Sonnet's job
- Produce overly detailed line-by-line implementations — write intent and key considerations, not execution
- Generate large amounts of boilerplate — scaffold with structure and comments, leave filling-in to Sonnet
- Go deep on a single file's implementation details — stay at the design and decision level
- Produce output that requires Sonnet to make major unresolved decisions — those decisions belong here

### Output philosophy
Every Opus output should be a handoff document. Ask before completing: "Can Sonnet pick this up and execute it without further planning?" If yes, the output is right-sized. If Sonnet would still need to make major decisions, add more detail. If the output is full of implementation specifics that don't require reasoning, strip them back — that detail belongs in Sonnet's hands, not here.

### Example: correct Opus output for a new feature
```
## Feature: User Authentication — Implementation Plan

### Decision: JWT with refresh tokens (not sessions)
Rationale: stateless, scales horizontally, team has existing JWT middleware.
Trade-off: refresh token rotation complexity. Accepted.

### Files to create/modify
- src/auth/jwt.service.ts — generate/verify tokens [SCAFFOLD: skeleton class, key methods stubbed]
- src/auth/refresh.service.ts — rotation logic [SCAFFOLD: interface + TODO for rotation algorithm]
- src/middleware/auth.middleware.ts — modify existing [NOTE: add refresh token check after line 47]

### Key considerations for Sonnet
- Token expiry: 15min access, 7d refresh
- Store refresh tokens in Redis, not DB (see ARCHITECTURE.md §Caching)
- Rotation: invalidate old token on use (sliding window)

### Open questions (resolve before Sonnet starts)
- Rate limiting strategy for refresh endpoint?
- Logout behavior: invalidate one device or all?
```

---

## Fable — Extended Planning / Long-Horizon Tier

Same behavioral rules as Opus, but appropriate for tasks that span multiple sessions, require sustained reasoning across very large contexts, or involve coordinating many moving parts over an extended period (multi-service migrations, large-scale refactors, multi-sprint planning).

Fable should still produce handoff documents, not production code. The difference from Opus is scope and duration, not output type.

---

## Model Switching Etiquette

When you recognize the current task is outside your tier:

1. **State the tier mismatch clearly** — "This is a planning-tier task. I'm running on Sonnet."
2. **Produce the best partial output for your tier** — an outline, a starting point, key questions to surface
3. **Label it as a handoff** — "Here's a Sonnet-ready skeleton. Switch to Opus to build out the architecture, then return to Sonnet to implement."
4. **Do not attempt full execution of an out-of-tier task** — a clearly labeled partial is more useful than an unlabeled attempt that looks complete but isn't

---

## Usage Note for Generated Toolkits

When this file is present in a generated toolkit, include a reference in CLAUDE.md and WORKFLOW.md so the model-aware behavior is surfaced at session start. The `/brief` skill should mention which model the toolkit was designed for if a specific model preference was set during generation.
