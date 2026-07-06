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

Skills load only when relevant — they do not bloat the context window when not needed. Use skills for domain-specific knowledge that should only activate during relevant work (e.g., a database skill loads only during DB work). See `CLAUDE_CODE_SKILLS_REFERENCE.md` for skill creation patterns.

---

**Version**: 1.1
**Last Updated**: 2026-07-05
