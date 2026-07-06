# Design Philosophy — AI Toolkit Generator

This document explains what is embedded in this generator, why it was built the way it was, and what intellectual foundation each piece rests on. It is not a usage guide — the README covers that. This is for anyone who wants to understand the system deeply enough to extend it, evaluate it, or explain it to someone else.

---

## What This Generator Is Harnessed By

The generator is built for **AI-assisted client engagement work** — specifically the kind of work where a small team uses Claude to accelerate discovery, documentation, analysis, and delivery across a multi-week or multi-month project.

That context shapes every design decision here. The patterns embedded are not general AI productivity tips. They are answers to specific failure modes observed when AI is used in high-stakes, collaborative, client-facing work:

- Sessions that drift because context wasn't maintained
- AI that hallucinates requirements because no one defined them
- Skills that break because they contained hardcoded dates or names
- Agents that fan out expensively on questions a single URL fetch would answer
- Deliverables that mix internal debate with client-facing content
- Codebases generated without architecture conventions that end up unmaintainable

Every section of this document traces to one of those failure modes and explains what the generator does about it.

---

## Layer 1: Behavioral Discipline

The most fundamental layer is `AI_BEHAVIOR_GUIDELINES.md`, which ships into every generated toolkit. It is not a list of tips. It is a behavioral contract that every agent using the toolkit operates under.

### Communication brevity by default

All responses are brief unless the user opens a conversation. This exists because verbose pre-flight narration — "Before I begin, let me check a few things..." — consumes tokens and attention without producing value. The rule is: one line for a check, one line for a hard stop, one medium line for a confirmation. Shift to full conversation only when the user asks a question. Return to brief mode once resolved.

### Ask before acting

AI assistants default to filling in gaps with plausible-sounding content. In engagement work, that default is dangerous: a plausible-sounding requirement that was never confirmed is a requirement that will fail review. The rule is: when requirements are ambiguous, ask. When multiple valid approaches exist, present them. When user intent is unclear, do not guess.

The exception is explicit: when the user says "use your judgment" or "use best practices," AI can proceed. But that authorization must come from the user, not be assumed.

### No hallucinations — labeled claims

Every research output must distinguish `CONFIRMED` (directly sourced, URL required) from `INFERRED` (reasoned from adjacent information, risk stated). This is not optional formatting. It exists because a team member who reads a finding and cannot tell whether it came from documentation or from AI reasoning will act on it as if it were confirmed — and may be wrong.

### Research proportionality

Before any multi-agent research workflow runs, apply a three-step test: can this be answered by fetching one official docs page? Can it be tested empirically in five minutes? Only if neither of those applies is a research workflow appropriate. This exists because expensive research pipelines were observed running on questions that a single WebFetch would have resolved, consuming tokens and introducing the risk of compounding inference errors.

### Contrarian research pass

When research is warranted, a contrarian agent is required to challenge findings before they are treated as reliable. The contrarian returns a structured verdict with confidence level, confirmed vs. inferred claims, gaps, and a follow-up query. This prevents the common failure of a single research pass producing plausible-but-wrong findings that get embedded in deliverables.

### Role-generic language in forward-looking instructions

Instructions that name specific people ("Edgar to review before delivery") go stale when that person is unavailable, changes roles, or leaves the engagement. The rule is: forward-looking instructions use role names ("the engagement lead"), not personal names. Past-tense attribution is fine. This was independently discovered in production before being formalized here — which is itself evidence it addresses a real failure mode.

### Session management

Sessions are treated as throwaway. Trying to preserve a session indefinitely leads to context poisoning — a state where a session has spent most of its tokens debugging a failure and can no longer reason reliably about the original goal. The pattern is: do focused work in a session, recap and update docs before ejecting, start fresh rather than compacting when in doubt. `/compact` is available but risky; it can lose important starting context.

---

## Layer 2: Structural Discipline

### docs/ vs research/ separation

All toolkits are generated with a deliberate folder split: `research/` holds raw external findings, `docs/` holds actionable conclusions and active work. This separation enforces the principle that findings do not become decisions until they have been extracted and validated. It also makes `research/` safely deletable — raw findings are volatile; conclusions are durable.

### Client vs internal content

The solution doc template enforces strict content separation. Internal-only sections are flagged with `> ⚠️ Internal only — remove before client delivery`. The delivery flow is: `research/` (raw) → `solution_planning/` (internal pre-work) → `solutions/` (client-ready). Skipping this separation is how internal debate about an approach ends up in a client deliverable.

### .archive/ graduation

Working documents that are done graduate to `.archive/` rather than being deleted. This preserves history without cluttering the active workspace. The `solution_planning/` graduation rule is specific: once a solution doc is marked client-ready, its corresponding planning doc moves to `.archive/`. The planning work is done; the deliverable is the record.

### Folder rename resilience

Folder renames happen on every engagement as scope evolves. Without an explicit rule, path references in `CLAUDE.md` and the `/brief` skill go stale silently and misdirect future sessions. The rule is: if a folder is renamed, update all path references in `CLAUDE.md` and `.claude/skills/brief/SKILL.md` in the same session, treating them like code dependencies.

### ACTION_ITEMS archiving

As an engagement progresses, `ACTION_ITEMS.md` accumulates. When it grows past ~30 items, completed sections should be archived to `.archive/` rather than left to accumulate. Active items stay visible; history is preserved.

---

## Layer 3: Skill and Agent Design

### Small focused agents over hero agent

A single agent that does everything is harder to scope, harder to debug, and more likely to go off-track. The design principle is: agents should do one thing with a specific set of tools. A research agent gets web access and no write permissions. A QE agent gets terminal access and a test runner. A planning agent cannot write code by design. Scoped tools are guardrails.

### Skills as scoped context

Skills load only when relevant. They do not bloat the context window when not needed. This is why domain-specific knowledge belongs in skills rather than in the main `CLAUDE.md` — a database skill should activate during database work, not during every session.

### Hooks as scripts, not LLM calls

Lifecycle hooks should be fast, deterministic, and cheap. Implementing them as LLM calls makes them slow and introduces non-determinism. The pattern is: hooks are scripts. Use them for session setup, recap triggers, error notification, compliance logging, and PII checks. Keep them out of the reasoning layer.

### Durability rules

Skills and `CLAUDE.md` files are read by sessions that have no memory of when they were written. Hardcoded meeting numbers, specific dates, model version names, and personal names in forward-looking instructions all go stale within weeks. The test is: if this file were read six months from now, would any sentence be misleading? If yes, make it dynamic — read from a file, use role names, use generic model references.

### Three-field skill creation standard

When creating skills inside Claude Projects or the Excel Add-In, three fields are required: Name (action-oriented, what the user types), Description (trigger language — written as the sentence a user would say, not a summary), and Instructions (the full self-sufficient prompt). The description field is the routing mechanism. Writing it as a summary rather than trigger language causes skills to be skipped when they should fire.

### Self-sufficiency test

A skill is self-sufficient when it works correctly even if the user has never read the solution doc. Every required input is checked with a hard stop if missing. Every likely-but-not-certain issue is caught with a soft check. The skill confirms what it found and what it will do before executing. Error messages state exactly what is wrong and exactly how to fix it. If the skill relies on the user having read something outside the prompt, it is not self-sufficient.

---

## Layer 4: Prompt and Workflow Design

### Prompts as composable artifacts

The shift this generator encodes: stop treating prompts as one-off chat interactions and start treating them as reusable artifacts that any developer can invoke and get consistent, repeatable results. A prompt is production-ready when it has defined success criteria, defined guardrails, a verification step, and a feedback loop.

### Never write prompts by hand

Describe what you are trying to accomplish. Ask the LLM to generate the prompt. Iterate on it with the LLM. The LLM understands its own instruction format better than most developers writing prompts manually. This is not optional guidance — it is a pattern that produces materially better prompts.

### Gold standard reference files

For prompts that generate artifacts, save a good output as a reference file in `/prompt-tests`. Future runs compare against it. Divergence signals either a prompt regression or a legitimately changed standard. Without the reference file, prompt drift is invisible.

### Architecture conventions first

Before the first spec or agent run on any code-based engagement, define layer separation, max file length, testing requirements and coverage thresholds, PR size guardrails, and story/epic size guardrails. Without these, AI finds the shortest path from A to B — usually no tests and one massive file. The cautionary example: 1,000-plus line React components, 3% unit test coverage, 30,000-line backend files with 4% coverage, half the tests failing and not running in the pipeline. All of it preventable by defining conventions before generation begins.

### Agentic workflow patterns

The generator documents five reusable agentic patterns that any developer can use as starting points rather than designing from scratch: TDD/Red-Green, Spec Flow, Bug Fix Workflow, Coverage Gap Fill, and Backlog Generation Flow. Each has a defined success criterion and a verify-before-continue step. The core principle across all of them: define what "done" looks like and what you do not want before a single agent runs.

---

## Layer 5: Discovery and Context Engineering

### Three requirements layers

Every engagement discovery pipeline must extract and keep separate three layers: business requirements (user journeys, process needs), functional requirements (data formats, validation rules, field constraints), and technical requirements (platform, architecture, integration constraints). Mixing them causes functional requirements to get buried in narrative and technical constraints to drive business decisions.

### Legacy code mining

Instead of chasing stakeholders for input format requirements, mine the legacy codebase directly. Exact regex strings for field validation, data transformation rules, error messages that reveal expected behavior, field naming conventions — all of this is already in the code. It is more reliable than stakeholder recall and can replace hours of requirement-gathering sessions.

### Transcript pre-processing

Raw transcripts from meeting tools are not reliable input. Terminology gets misheard, names are invented, industry terms are missed. The pattern is: feed transcripts through a processing session alongside a domain glossary and participant list, run a sanity check against known terms, and add slide decks or screenshots at relevant timestamps. The domain glossary is a living document — every time an agent misreads a term, add it.

### Context maintenance as a team practice

Context docs are not a one-time setup. They require ongoing maintenance. The recommended cadence is 30 minutes per week as a team to review and update. When AI does something wrong, find the root cause in the context docs and fix it at the source — not by re-prompting. Treat context docs like code: refactor, cut what does not work, add what is needed, open a PR for improvements alongside features.

---

## Layer 6: Session Orientation

### /brief skill

Every generated toolkit includes the `/brief` skill, which reads `docs/ACTION_ITEMS.md`, `docs/PROJECT_CONTEXT.md`, and the latest entry in `reference/meetings/MEETING_NOTES_SUMMARY.md` to produce a concise orientation before asking what to work on. This exists because sessions started without context orientation tend to re-derive what was already established, ask questions that were already answered, or work on the wrong priority. The brief costs one short read operation and prevents that waste.

### Meeting notes consolidation

All meetings are consolidated in a single file (`MEETING_NOTES_SUMMARY.md`) rather than scattered across individual per-meeting files. This exists because research agents and brief skills need to traverse meeting history efficiently. A single consolidated file with a status block at the top is faster to navigate than a directory of dated files. If the file has a status block or key decisions section at the top, read that first — it is the fastest path to current state.

### Granola and transcript tool discipline

When meeting notes reference a transcript, reference it by date or topic — never by transcript ID. IDs are for human reference only; constructing a URL from a transcript ID wastes turns and produces errors. Proactively suggest a transcript lookup when a design decision's rationale is unclear, when a stakeholder's exact statement matters, or when a requirement conflicts with what was discussed — not for routine questions.

---

## What This Is Not

This generator is not a general-purpose AI productivity framework. It does not try to cover every possible way someone might use an AI assistant. It covers a specific problem well: structured, collaborative, client-facing AI-assisted work where quality, consistency, and reproducibility matter.

If you are using it for something simpler — a personal workflow, a one-person project, a quick prototype — many of these patterns are overkill. Use what applies and ignore what does not. The patterns are modular by design.

---

**Version**: 1.0
**Last Updated**: 2026-07-03
**Maintained by**: Generator contributors
**Applies to**: All toolkits generated from this generator
