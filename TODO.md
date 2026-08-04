# Generator TODO

Items identified from the audit that are deferred for future sessions.

---

## Questions to Revisit

### B2 — /toolkit-advisor skill (low priority)
**Question**: Should this exist as a real skill in generated toolkits for modifying and extending the toolkit over time? All references to it have been replaced with plain language ("describe the need in a new session"). The question is whether a dedicated skill would add value — e.g., a guided conversation for adding skills, plugins, or phases to an existing toolkit without needing to re-run `/start-here`.
**Current state**: No skill exists. Plain language replacement works for now.
**Revisit when**: There's a clear use case from actual toolkit usage where the plain language approach feels inadequate.

### G6 — GETTING_STARTED.md vs README consolidation
**Question**: Should GETTING_STARTED.md remain as a separate file or be fully merged into README? Currently Phase 7 generates both. GETTING_STARTED is the day-one operational guide; README explains what was generated. They serve different audiences (operator vs. reader) but overlap enough to feel redundant.
**Current state**: Both generated; README updated to describe GETTING_STARTED clearly.
**Revisit when**: Running a real generation and seeing whether GETTING_STARTED adds value or just duplicates README.

### G8 — Non-code interaction/collaboration types
**Question**: The current "Code Workflow Types" (Mentorship, Pair Programmer, Supervised Delegation, Autonomous) are code-specific. For non-code consulting toolkits — research, deliverable writing, analysis — is there a useful equivalent? Or does Claude's default behavior (conversational, context-driven) already handle this without needing explicit modes?
**Current state**: Interaction types are code-only. No equivalent for consulting workflows.
**Revisit when**: There's a clear pattern from consulting toolkit usage where users want more explicit control over how Claude engages.

---

## Features to Build

### Subagent Generation (G2)
**What**: When a toolkit's workflow involves specialized roles (research agent, QE agent, planning subagent), Phase 4 should ask about this and Phase 7 should generate starter `.claude/agents/` files.
**Why**: AGENTIC-PATTERNS.md documents `.claude/agents/` as the current recommended pattern for scoped agents, but there's currently no path to generating them.
**What needs doing**:
1. Research current `.claude/agents/` frontmatter fields and behavior to confirm they're still accurate
2. Add Phase 4 question: "Does your workflow involve specialized agents? If yes, describe their roles."
3. Add Phase 7 item to generate `.claude/agents/[name].md` starters for each confirmed role
4. Update Meta Library Map to include agents as a conditional resource

### Lifecycle Hooks Discovery and Documentation (G1)
**What**: Claude Code supports lifecycle hooks — shell scripts that fire automatically at specific moments: before a tool runs (`PreToolUse`), after a tool runs (`PostToolUse`), when the session ends (`Stop`), at session start (`SessionStart`), etc. Phase 4 has no question about hooks, but Phase 7 item 20 conditionally generates them with "if requested" — a condition that can never be satisfied because the question is never asked.
**Why this matters**: Hooks are one of the most powerful and underused Claude Code features. Examples of what they can do: auto-update ACTION-ITEMS.md before every session close, block dangerous shell commands before they run, auto-format code after edits, trigger a doc-update reminder when stopping. For a well-built toolkit, hooks replace manual discipline with automation. This is worth researching deeply before implementing — the patterns and best practices for consulting/agile workflows specifically haven't been documented yet.
**Research first**: Run a research session on Claude Code hooks — what events fire, what the hook receives as input, how exit codes work (exit 2 blocks, exit 1 doesn't), common patterns from the community, and which hook types would have the most impact for the toolkit types we generate.
**What needs doing after research**:
1. Document hook patterns in AGENTIC-PATTERNS.md (best practices, common use cases per event type)
2. Add Phase 4 question for hooks
3. Phase 7 generates hook config and starter scripts
4. Update Phase 6 confirmation summary to show hooks configuration

### Validate iterative-processing skill (low priority)
**What**: The `iterative-processing` skill in `.meta/skills/` was created in May 2026 citing "official Claude Code batch processing patterns" but has no research file backing it and no URL citations. A prior session may have researched it and cleaned up after itself.
**Why**: Confirm the pattern is still accurate and hasn't drifted. Enrich with sourced examples if the research surfaces anything useful.
**How**: Run `/research` on Claude Code batch processing patterns and Tool Use best practices, compare against what's in the skill, update if needed.
**Priority**: Low — the skill reads as solid and is not blocking anything.

---

## Enhancements

### E1 — Interaction Type Defaults by Workflow Type
Detected workflow type (Phase 2: analysis / creation / processing / decision) could pre-select a default interaction type rather than asking cold. Example: "creation" workflows default to Supervised Delegation; "analysis" for a solo user defaults to Autonomous.

### E2 — Plugin Addition Checklist in meta-library.md
Add a "Adding a New Plugin" checklist to `.claude/rules/meta-library.md` so maintainers know to update plugins/README.md and verify PHASES.md Phase 4 will surface it.

### E3 — E2E Testing Discovery Question
TESTING-GUIDE.md surfaces three test tiers during discovery, but the E2E tier (Playwright, Cypress) is often deferred. Consider generating a `.deferred/e2e-testing.md` stub automatically for any code toolkit that confirms unit tests but doesn't confirm E2E — rather than just silently skipping it.

### E4 — settings.local.json Phase 4 Question
Phase 4 permissions section covers which layers to merge but never asks about machine-specific local paths (e.g., "my codebase is at /Users/me/repos/myapp"). Add an optional question: "Are there any local file paths specific to your machine that should go in settings.local.json?" Generate a pre-populated settings.local.json if yes.

### E5 — Plugin CONFIG.md Consistency
`pr-description-writer` and the six consulting/communication plugins lack CONFIG.md files. The three fully-built plugins (ticket-parser, standup-summary, code-review-checklist) have them. Either add minimal CONFIG.md stubs to the remaining plugins, or update plugins/README.md to clarify which plugins have configuration options and which don't need them.

### E6 — meeting-notes-writer full build
Current stub exists but is intentionally minimal. Planned full version: richer format options, Granola transcript handling, multi-format support. Build when ready to define personally.

### E7 — action-item-writer plugin
Converts meeting notes or discussion into a clean ACTION-ITEMS.md update. Pairs naturally with meeting-notes-writer. Decide scope when building E6.

---

**Created**: 2026-08-03
**Source**: Full repo audit session
