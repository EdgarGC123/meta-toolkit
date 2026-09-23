# Model-Tier-Aware Behavior Rules

**Purpose**: How Claude should behave based on which model tier it is running on.
**Status**: Validated against research (`research/model-tiers-capabilities.md`, `research/model-settings-cost.md`). Ready to apply — not yet promoted to `AI-BEHAVIOR-GUIDELINES.md`. See `TODO.md`.
**Self-detection**: Claude Code injects the running model into the session prompt. Match loosely on tier names (Haiku / Sonnet / Opus / Fable) — Bedrock uses provider-prefixed IDs like `us.anthropic.claude-opus-5[1m]`.

---

## The Primary Axis: Autonomy, Not Difficulty

**The right question is not "how hard is this task?" — it's "how long before I need to course-correct?"**

A hard task done interactively with a human confirming each step can run on Sonnet. A routine task that runs for two hours without human checkpoints needs Fable. The tier should match the *unsupervised duration*, not the complexity of any individual step.

Practical decision tree:
1. Will this run for minutes with regular human input? → Sonnet
2. Will this run for an extended period reading/writing many files without check-ins? → Opus or Fable
3. Is this a single well-defined task on known content, repeated many times? → Haiku
4. Is this days-long, context-spanning autonomous work? → Fable

---

## Tier Map

**CONFIRMED** — sourced from official Anthropic model docs

| Model | Tier | Horizon | Primary role |
|---|---|---|---|
| Haiku 4.5 | Read-and-summarize | Seconds per item, human-supervised | Repetitive single-file tasks, extraction, documentation of known content |
| Sonnet 5 | Execution | Minutes to hours, regular check-ins | Day-to-day implementation, story work, interactive development |
| Opus 5 | Deep reasoning | Hours, infrequent check-ins | Complex analysis, architectural decisions, long autonomous loops |
| Fable 5 | Extended autonomous | Multi-hour to multi-day | Very long autonomous runs, large context, cross-boundary discovery |
| Mythos 5 | Restricted | N/A | Invitation-only (Project Glasswing, defensive cybersecurity). Not available for standard use. |

**Note on Opus 4.8**: Legacy. Use Opus 5 for new work.
**Note on Sonnet 4.6**: Previous generation. Sonnet 5 is now the default at $2/$10 per MTok.

---

## Haiku — Read-and-Summarize Tier

**Best for**: Repetitive, well-scoped tasks on known content where each item is simple but there are many of them. The cost advantage is real — but only when the task genuinely doesn't require reasoning.

**Strongest use case**: Reading an existing codebase file-by-file and documenting what each file/component does. Each task is bounded ("read this file, describe its purpose and key exports"), human-supervised, and requires no planning. Running Sonnet or Opus here wastes money without improving output quality.

### Do
- Read one file and summarize its purpose, exports, dependencies
- Extract specific data from a known format (ticket fields, log lines, CSV rows)
- Classify or label items from a fixed taxonomy
- Generate boilerplate matching an explicit pattern already in the codebase
- Populate APP-CONTEXT.md or similar reference docs file-by-file under human direction

### Hard constraints — these are platform limits, not style preferences
- **No effort parameter** — Haiku has no `effort` dial. You cannot increase its reasoning depth.
- **200K context window** — not 1M. Cannot ingest a full large codebase in one pass.
- **Knowledge cutoff: Feb 2025** — will not know about libraries, APIs, or patterns released after that date.
- **Claude Code refuses to plan on Haiku** — if a task requires Claude Code's planning mode, it will not run on Haiku.

### When asked to do Sonnet/Opus-tier work
State the constraint, don't attempt: "This task requires multi-file reasoning / planning. I'm running on Haiku, which can't do this reliably. Switch to Sonnet."

---

## Sonnet — Execution Tier (Default)

**Best for**: Most day-to-day work with regular human engagement. Interactive development, story implementation, bug fixes. If you're checking in every few minutes, Sonnet is almost certainly the right choice.

### Do
- Implement a well-defined story with clear ACs
- Write, edit, and test code across multiple related files
- Debug bugs with a known reproduction path
- Write tests at any tier (unit, integration, E2E)
- Execute a plan that already exists as a document
- Run the agile story workflow end-to-end with human check-ins
- Update reference files (APP-CONTEXT.md, ARCHITECTURE.md) based on exploration

### When to consider Opus instead
The signal is not "this is hard" — it's "I'm about to walk away and let this run." Or: "This requires connecting dots across the whole system that I can't spell out in a prompt." If you're specifying each step, Sonnet can handle it. If the model needs to figure out the steps itself across large context, that's Opus territory.

---

## Opus — Deep Reasoning Tier

**Best for**: Tasks that require genuine reasoning under complexity — where the model needs to understand a large system, make non-obvious connections, or run for a significant period without human direction.

**Key research finding**: Opus 5 is explicitly designed to complete features fully — *without* leaving stubs or placeholders. Do not instruct it to "scaffold and hand off to Sonnet" unless the work genuinely exceeds what fits in one context. If it fits in one context window, Opus completing it outright beats the plan-handoff-execute overhead.

**Also confirmed**: Opus 5 and Fable 5 self-verify. Do not add "verify twice before submitting" instructions — they cost tokens for no quality gain. One verification pass is what the model does by default.

### Do
- Complete multi-file features end-to-end when the scope is clear
- Analyze an unfamiliar codebase and produce APP-CONTEXT.md or ARCHITECTURE.md
- Design systems where the right answer requires understanding trade-offs you haven't fully specified
- Run long exploratory sessions across a large codebase
- Make architectural decisions with rationale documented for the team
- Produce durable reference documents (plans, ADRs, context files) that will outlast the session

### When to lower effort rather than switch models
If Opus is the right tier (the task needs its reasoning) but you're paying for `high` effort on work that doesn't need deep thinking — lower the effort. Anthropic's finding: effort tuning is often a better lever than switching models. The quality tradeoff is more favorable than the cost implies.

### When segmenting by model adds value
- Work that **genuinely exceeds one context window** — then you must segment
- **Routine work at high volume** — then cheaper models save real money per item
- **Not** as a default for "complex" work that fits in one context — in those cases, a single Opus session at appropriate effort beats the plan-handoff-execute cost

---

## Fable — Extended Autonomous Tier

**Best for**: Work that runs for a very long time without human checkpoints. Multi-hour autonomous sessions, cross-boundary discovery, very large context spanning many services or files.

**What distinguishes Fable from Opus** is not capability per step — it is sustained reliability over long horizons. Fable maintains quality and doesn't drift over extended runs where Opus would.

**Operational constraints to know**:
- Slower response latency (7.9–11.4 hour episodes measured in research)
- Not ZDR (Zero Data Retention) eligible
- Billed on usage credits in headless mode — fires silently without a per-turn display
- Not the better *coding* model — Opus 5 matched Fable on SWE-bench Pro at ~60% of the cost for supervised coding work

Use Fable when the session genuinely needs to run for hours unsupervised. Use Opus when you're present and engaged.

---

## Model Switching Etiquette

When you recognize the current task is outside your tier:

1. **Name the mismatch** — "This requires reasoning across the full service graph. I'm running on Sonnet."
2. **Produce the best partial for your tier** — an outline, a starting point, flagged gaps
3. **Label it clearly** — "Here's a Sonnet-level starting point. This task's scope fits Opus better."
4. **Don't attempt a full out-of-tier task unlabeled** — a labeled partial is more useful than an unlabeled attempt that looks complete

---

## Practical Workflow: Codebase Onboarding

This sequence applies the autonomy axis to a common consulting/development pattern:

**Phase 1 — Setup** (Sonnet or Haiku)
Run `/start-here` to generate the toolkit. Low-complexity, interactive, one-time. Sonnet is appropriate. Haiku can handle it if the setup questions are straightforward.

**Phase 2 — Codebase mapping** (Haiku)
Read through the repository file-by-file and populate APP-CONTEXT.md and ARCHITECTURE.md. Each task: "read this file, describe its purpose, note key exports and dependencies." Human-supervised, repetitive, well-scoped. This is exactly what Haiku is built for. Token cost is a fraction of running Sonnet or Opus for the same work, and output quality is comparable because the task requires recognition, not reasoning.

**Phase 3 — Day-to-day work** (Sonnet, or Haiku for simpler stories)
Once context docs exist, Sonnet runs stories against them. For well-defined tickets where the ACs are clear and the codebase context is loaded, Haiku may be sufficient. For stories requiring multi-file changes, debugging, or judgment calls — Sonnet.

**Phase 4 — Architectural decisions** (Opus when needed)
When a story surfaces a genuine architectural question, or when you need to design something non-obvious, switch to Opus. Don't stay on Opus for implementation after the decision is made.

---

## Usage Note for Generated Toolkits

When this file is incorporated into generated toolkits:
- Reference it in CLAUDE.md so it surfaces at session start
- WORKFLOW.md should note which tier is recommended per phase, based on Phase 4 discovery answers about autonomy and session length
- The `/brief` skill should surface the recommended model if a preference was recorded during generation
