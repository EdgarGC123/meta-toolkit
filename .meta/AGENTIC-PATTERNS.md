# Agentic Workflow Patterns

**Purpose**: Reference for developers designing agentic prompts and multi-agent workflows

These patterns are reusable. Any developer can invoke them as a starting point rather than designing from scratch.

---

## Core Principles

### Success Criteria First

Always define what "done" looks like and what you do NOT want before a single agent runs. Without this, AI finds the shortest path from A to B — usually no tests and one massive file.

Define in your context docs before starting:
- What the output must contain
- What the output must not do (no tests, no monolithic files, no out-of-scope changes)
- What "verified" means (test passing, human review, automated check)

### Bounded Autonomy

Always include a "verify with me before you do it" step. Do not let 50 files change before you check in. Set explicit stopping points: "Stop after X and confirm before continuing."

### Transparency via Scratch Log

Have the agent write a log file of what it did, why, and what tools it invoked. Review it to optimize and correct. This surfaces unexpected behavior early.

### Never Write Prompts by Hand

Describe what you are trying to accomplish. Ask the LLM to generate the prompt. Iterate on the prompt with the LLM. This applies to all prompts — skill prompts, agent prompts, workflow prompts.

### Self-Updatable Prompts

If an agent does something unexpected, instruct it to revise the prompt itself. Build this into your workflow: "if the output does not match what I expected, update this prompt to correct the behavior."

### Gold Standard Reference Files

For artifact-generating prompts (PRDs, reports, solution docs):
1. Run the prompt once and produce a good output
2. Save that output as a gold standard reference file in a `/prompt-tests` folder
3. Add a step to the prompt: compare output to the reference file
4. If divergence: either update the reference or fix the prompt

### Small Focused Agents Over Hero Agent

Prefer agents that do one specific thing with a specific set of tools. Examples: ADO skill, JIRA skill, Figma skill, QE agent, Developer agent. A single agent trying to do everything is harder to debug, harder to scope, and more likely to go off-track.

---

## Pattern 1: TDD / Red-Green

Use when: Building new functionality and you want tests to drive the implementation.

```
QA agent analyzes business requirements
  → writes all tests
  → tests run: they should fail (red)
Implementation agent runs
  → tests rerun
  → green = done
  → if not green: fix → rerun → repeat
```

**Why red first**: A test that passes before the implementation exists is not a real test. Confirming red gives you confidence the test is meaningful.

---

## Pattern 2: Spec Flow (Implementation Planning)

Use when: Building from a defined spec or story.

```
Create the spec
  → Plan it out
  → Build it
  → Test hook fires after implementation
    → if green: done
    → if not: fix → rerun → repeat
```

**Key step**: The spec must include architecture conventions (layer separation, file size limits, test requirements) before any implementation agent runs.

---

## Pattern 3: Bug Fix Workflow

Use when: A bug ticket exists and needs a consistent, reproducible fix process.

```
Step 1: Invoke JIRA/ADO skill → pull the bug ticket → parse current vs expected behavior
Step 2: Agent searches codebase → echoes location back → human confirms
Step 3: QE Agent writes a failing test against expected behavior → run it → confirm it fails (red)
Step 4: Developer Agent implements the fix
Step 5: Rerun tests → confirm green → prompt execution ends
```

Any developer can invoke `/bug-fix` and get consistent output across any ticket.

---

## Pattern 4: Coverage Gap Fill

Use when: A codebase has low test coverage and you need to improve it systematically.

```
Target a module/Lambda
  → Sub-agents in a loop write unit tests to a threshold
  → Move to next lowest-covered module
  → Keep going until threshold met
```

**Important**: Define the threshold before starting. "80% coverage" is a success criterion; "more tests" is not.

---

## Pattern 5: Backlog Generation Flow

Use when: Starting an engagement with raw artifacts (transcripts, legacy code, Slack messages) and needing a workable backlog.

```
Raw artifacts (transcripts, legacy code, Slack)
  → Pre-process and clean
  → Extract three requirements layers (business / functional / technical)
  → Generate PRD
  → Generate epics top-down (cohesive epics → stories → acceptance criteria)
  → Mine acceptance criteria from transcripts and legacy code
  → Use lifecycle hooks to check: "Is this acceptance criteria actually testable?"
  → Result: workable backlog with fewer refinement sessions needed
```

**Note on waterfall risk**: Doing lots of upfront discovery can feel like waterfall. The goal is a better starting point, not a locked plan. Blend upfront context richness with iterative development.

---

## Agent Design Principles

### Subagents — The Current Pattern for Scoped Agents

**CONFIRMED** — sourced from https://code.claude.com/docs/en/sub-agents

In Claude Code, custom agents are now defined as **subagents** — Markdown files with YAML frontmatter saved in `.claude/agents/` (project-scoped) or `~/.claude/agents/` (personal, all projects). Each subagent has its own system prompt, tool list, model, and permissions.

```markdown
---
name: research-agent
description: Searches documentation and web sources. Use when current information about a tool or API is needed.
tools: Read, WebSearch, WebFetch
model: sonnet
---

You are a research specialist. Search primary sources first...
```

Key fields:
- `tools` — explicitly list what this agent can use; unlisted tools are denied
- `model` — can be set independently (e.g., use Haiku for cheap classification agents)
- `description` — how Claude decides when to delegate to this agent; write it as the sentence a user would say

Built-in subagents include `Explore` (read-only codebase search), `Plan` (research for plan mode), and `general-purpose` (full tools). Define custom subagents for domain-specific work.

### Tool Scoping via Subagents

Scope tools at the subagent level rather than through settings.json alone:
- A research subagent: `tools: Read, WebSearch, WebFetch` — no write access
- A planning subagent: `tools: Read, Grep, Glob` — read-only, no editing
- A QE subagent: `tools: Read, Bash(pytest *), Bash(npm test *)` — test runner only

This provides explicit guardrails and prevents agents from doing things outside their intended scope.

### Hooks as Scripts, Not LLM Calls

Lifecycle hooks (PreToolUse, PostToolUse, Stop, SessionStart, SessionEnd) should be implemented as scripts, not LLM calls. Keep them fast.

Current hook events: `PreToolUse`, `PostToolUse`, `Stop`, `SubagentStop`, `UserPromptSubmit`, `SessionStart`, `SessionEnd`, `Notification`

Use hooks for:
- `PreToolUse`: block dangerous commands, enforce policy, validate before execution
- `PostToolUse`: auto-format after edits, log tool activity
- `Stop`: run recap/doc-update logic before session ends
- `SessionStart`: environment setup

Key rule: use `exit 2` (not `exit 1`) to block — exit code 1 is non-blocking.

### Skills as Scoped Context

Skills load only when relevant — they do not bloat the context window when not needed. Use skills for domain-specific knowledge that should only activate during relevant work (e.g., a database skill loads only during DB work). See `CLAUDE-CODE-SKILLS-REFERENCE.md` for skill creation patterns.

---

## Session Memory Patterns

### The Problem
Claude sessions are stateless. Everything learned in session N is lost in session N+1 unless
it is written to a file. For long-running engagements or complex codebases, this means
compounding re-derivation cost across every session.

### Pattern: Living Reference Files
Create files that accumulate knowledge and are loaded at session start.

Structure:
- `PROJECT-CONTEXT.md` — engagement context, team, conventions (loaded by /brief)
- `APP-CONTEXT.md` — codebase navigational map, feature locations (loaded by /brief)
- `ARCHITECTURE.md` — patterns and conventions, how the app works (loaded by /brief)

Update discipline: the workflow must explicitly include a step to update these files
before the session closes. Knowledge that stays only in the conversation is lost.

Rule of thumb: "If Claude had to figure this out, write it down."

### Pattern: Warm Session Start
Wire /brief to load all living reference files at session start:
1. Read `ACTION-ITEMS.md` (current tasks)
2. Read `PROJECT-CONTEXT.md` (engagement context)
3. Read `MEETING-NOTES-SUMMARY.md` (latest meeting)
4. Read `reference/*/APP-CONTEXT.md` (codebase maps)
5. Read `reference/*/ARCHITECTURE.md` (architectural patterns)

Result: the session starts with full context rather than a blank slate.

### Pattern: End-of-Session Update Checklist
Include in WORKFLOW.md for any toolkit with living reference files:
- [ ] APP-CONTEXT.md updated with any new areas explored
- [ ] ARCHITECTURE.md updated if a new pattern was understood
- [ ] PROJECT-CONTEXT.md updated with any new team/process knowledge
- [ ] ACTION-ITEMS.md reflects current state

### Why This Matters for Large Codebases
On a large existing app, the first session does heavy lifting: mapping the codebase,
understanding patterns, finding where features live. Without written records, session 2
starts from scratch and pays the same cost again. With APP-CONTEXT.md and ARCHITECTURE.md,
session 2 loads a map instead of re-reading the repo. The investment pays off after
the first story.

---

## Code Workflow Interaction Types

For code toolkits, Claude can operate in four distinct interaction types. These govern the working relationship style during implementation and testing work. They are distinct from the behavioral rules in `AI-BEHAVIOR-GUIDELINES.md` (which govern how Claude acts regardless of mode).

Note: these modes are specific to code workflows. For non-code consulting work, the primary interaction is conversational and these modes don't apply.

Define the default in WORKFLOW.md and document the activation phrases so the user can switch on request.

### Mentorship
Human works, Claude coaches. For every change: Claude proposes the approach, explains why, flags all other files that will need to change, and waits for the user to proceed. The user drives; Claude navigates. Human retains full understanding of everything produced.

Best for: implementation phases where the user is learning the codebase or wants to build understanding, not just complete the ticket.

Activation phrase: "mentorship mode" or "guide me"

### Pair Programmer
Human and Claude co-create. Claude generates and explains patterns as it goes — not just producing output but showing the reasoning behind it (why this mock structure, why this data flow). Human directs and steers; Claude executes and teaches simultaneously. Tests are produced and explained, not just generated.

Best for: test writing, unfamiliar patterns, or any phase where the user wants to build skill alongside output. Replaces the narrower "pattern-teaching" concept — this mode applies across the whole workflow, not just tests.

Activation phrase: "pair mode" or "explain as you go"

### Supervised Delegation
Human specifies a task and checkpoints; Claude executes with approval gates at meaningful decision points. Claude moves with speed and confidence but pauses before touching a new file, making a non-obvious assumption, or choosing between two valid approaches — surfaces a clear recommendation with brief rationale and waits for confirmation. Human owns all decisions; Claude owns the execution between them.

Practical behaviors:
- Before touching any new file: "I'm about to edit X to do Y — confirming before I proceed"
- Before making an inference: "I'm assuming Z based on what I see — is that right?"
- After completing a logical unit: brief summary of what was done and what comes next, checkpoint before continuing
- If something is uncertain: state confidence explicitly and offer the two most likely options rather than guessing

Best for: when the user wants the output without writing every line, while maintaining enough control to catch mistakes before they compound.

Activation phrase: "supervised mode" or "you drive"

### Autonomous
Human assigns a scoped task; Claude executes end-to-end; human reviews the finished artifact. No approval gates mid-execution. Claude stops only if it hits a genuine blocker that requires a decision it cannot make.

Best for: well-defined, bounded tasks where the user is confident in the scope and trusts the output. Also covers quick one-off tasks where oversight overhead isn't worth it.

Activation phrase: "just do it" or "autonomous mode"

---

### Surfacing Code Workflow Interaction Types During Generation

Ask the interaction type question for code toolkits only (Q3 = yes), twice — once for implementation, once for testing. They can be the same or different, and setting them separately is worth surfacing explicitly.

**For implementation:**
```
"How do you want Claude to work with you on implementation?
  1. Mentorship — you write code, Claude coaches and explains tradeoffs
  2. Pair Programmer — Claude generates and explains patterns as you co-create
  3. Supervised Delegation — Claude executes, pauses at every key decision for your approval
  4. Autonomous — Claude executes end-to-end, you review at the finish
  5. Mixed — set a default per phase, switch on request"
```

**For testing (if any test tier was confirmed):**
```
"For tests specifically — same mode, or different?
  1. Same as implementation
  2. Mentorship — you write tests, Claude coaches on structure and coverage
  3. Pair Programmer — Claude writes tests and explains the pattern (why this mock, why this assertion)
  4. Supervised Delegation — Claude writes tests, pauses at structural decisions
  5. Autonomous — Claude writes all tests, you review at the end"
```

In generated WORKFLOW.md for code toolkits, add a "Code Workflow Interaction Types" section with one entry for implementation and one for testing, the activation phrases for each, and how to switch mid-session.

---

**Version**: 1.2
**Last Updated**: 2026-07-29
