# Batch / Iterative Processing Patterns — Research Reference

**Research date**: 2026-08-21
**Confidence**: High on the platform facts — 11 sources, all Tier 1 (Anthropic product docs and Anthropic Engineering), all fetched live this session. Medium on the "is the existing skill still right" verdict, which is my synthesis rather than a sourced claim. One standing caveat: this research is **entirely vendor documentation**. No independent practitioner reports were gathered, so the numbers and limits are trustworthy but the "this works well in practice" framing is unaudited (see Gaps).
**TODO reference**: "Validate iterative-processing skill (low priority)"
**Purpose**: Decide whether `.meta/skills/iterative-processing/` should be kept as-is, corrected, or rewritten before it propagates into more generated toolkits.

---

## Key Finding

The abstract loop the skill describes (load → process → validate → accumulate → review) is still sound and is indirectly endorsed by Anthropic's own guidance, but the skill's stated provenance is wrong and its mechanics are a generation behind. There is **no Anthropic document called "Claude Code batch processing patterns"** — "batch processing" in Anthropic's docs means the **Message Batches API** (a server-side async API, 50% cheaper), which is a completely different thing from what the skill describes. Meanwhile Claude Code has shipped three first-class, documented mechanisms for exactly this pattern that the skill does not mention at all: the **`/batch` skill**, **subagent fan-out**, and **dynamic workflows** (`pipeline()`). The skill's numeric thresholds (10-20 / 20-100 / 100+ items) are not grounded in anything I could source; the real documented thresholds are about **agent concurrency and context**, not item counts.

---

## Findings

### 1. Does Anthropic document "official batch processing patterns"?

- **CONFIRMED [1]**: Anthropic's page titled "Batch processing" is about the **Message Batches API** — server-side asynchronous processing of many independent Messages API requests. Its opening line: "Batch processing is a powerful approach for handling large volumes of requests efficiently." It is an API surface, not a Claude Code workflow pattern.
- **CONFIRMED [1]**: That page's only "Best practices for effective batching" section says exactly four things: (a) "Monitor batch processing status regularly and implement appropriate retry logic for failed requests"; (b) "Use meaningful `custom_id` values to easily match results with requests, since order is not guaranteed"; (c) "Consider breaking very large datasets into multiple batches for better manageability"; (d) "Dry run a single request shape with the Messages API to avoid validation errors."
- **CONFIRMED [2][4][5][6]**: For Claude Code specifically, the closest official material is in three places, none of which is titled "batch processing patterns": the best-practices page's **"Fan out across files"** section, the bundled **`/batch`** skill, and the **dynamic workflows** page. All three postdate or sit alongside the skill's May-2026 creation date and none is cited in it.
- **INFERRED**: The skill's "Source: Based on official Claude Code batch processing patterns and Tool Use best practices" line is not traceable to any document. Reasoning: I fetched the Claude Code best-practices, subagents, workflows, commands, tools-reference, headless, and costs pages plus the API batch-processing page and found no such titled source. Risk if wrong: low — the claim is decorative, but it makes the file look sourced when it isn't, which is the exact failure the generator's own research skill warns about.

### 2. The Message Batches API — is it relevant, and what are the numbers?

Relevant as an **alternative**, not as an implementation of the skill. Use it when you have many *independent, non-interactive* LLM calls and can wait.

- **CONFIRMED [1]**: 50% discount. "All usage is charged at 50% of the standard API prices." Applies to "input tokens, output tokens, and any special tokens."
- **CONFIRMED [1]**: Batch size limit — "A Message Batch is limited to either **100,000** Message requests or **256 MB** in size, whichever is reached first." Exceeding size gives a `413 request_too_large`.
- **CONFIRMED [1]**: Timing — "most batches finishing in less than 1 hour"; results accessible "when all messages have completed or after 24 hours, whichever comes first"; "Batches expire if processing does not complete within 24 hours."
- **CONFIRMED [1]**: Results retained 29 days from `created_at` (not from `ended_at`).
- **CONFIRMED [1]**: Result ordering — **not guaranteed**. Four result types per request: `succeeded`, `errored`, `canceled`, `expired`. You are **not billed** for `errored`, `canceled`, or `expired` requests.
- **CONFIRMED [1]**: Isolation of failure — "Note that the failure of one request in a batch does not affect the processing of other requests." This is the strongest Tier-1 statement supporting the skill's "one failure shouldn't stop the batch" rule.
- **CONFIRMED [1]**: All active models supported. Almost everything can be batched (vision, tool use, all server tools, multi-turn, extended thinking, most betas). Not supported inside a batch: `stream: true`, `speed` (fast mode), `store`/`previous_thread_event_id` (threads), `cache_hint`/`context_hint`, `max_tokens: 0`, `research_preview_2026_02`.
- **CONFIRMED [1]**: Prompt caching works but "cache hits are provided on a best-effort basis" because requests run concurrently and in any order. Docs recommend the **1-hour cache duration** for batches with shared context.
- **CONFIRMED [1]**: Batches API rate limits are separate — "Usage of the Batches API does not affect rate limits in the Messages API."
- **CONFIRMED [1]**: Batches "may go slightly over your Workspace's configured spend limit" because of concurrency.
- **CONFIRMED [1]**: Recommended to **stream** results rather than download all at once, "Because of the potentially large size of the results."

**When to prefer it over a sequential loop**: high volume, no interactivity needed, cost-sensitive, uniform per-item prompt. **When not to**: you need per-item tool use inside *your* environment (file edits, repo access), interactive review, or results within seconds.

### 3. Subagent fan-out in Claude Code — better than a sequential loop?

Yes for isolation and context, but with real, documented limits and a cost multiplier.

- **CONFIRMED [3]**: "Each subagent starts with a fresh, isolated context window. It doesn't see your conversation history, the skills you've already invoked, or the files Claude has already read."
- **CONFIRMED [3]**: The single strongest reason to fan out is context, not speed: "One of the most effective uses for subagents is isolating operations that produce large amounts of output... the verbose output stays in the subagent's context while only the relevant summary returns to your main conversation."
- **CONFIRMED [3]**: Documented per-item fan-out pattern via nesting: "a reviewer subagent that dispatches a verifier per finding, so the intermediate output never reaches your main conversation."
- **CONFIRMED [3]**: Concurrency cap — "By default, when **20 subagents are running** in a session, spawning another with the Agent tool fails with `Concurrent subagent limit reached`, and the error tells Claude not to retry." Tunable via `CLAUDE_CODE_MAX_CONCURRENT_SUBAGENTS`. There is **no limit on the total number** spawned over a session.
- **CONFIRMED [3]**: Nesting depth default is **3** layers below the main conversation (`CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH`; `1` disables nesting).
- **CONFIRMED [3]**: The documented counter-warning for naive fan-out: "Running many subagents that each return detailed results can consume significant context." For sustained parallelism or work exceeding the context window, docs point to agent teams or workflows instead.
- **CONFIRMED [3]**: Cost controls for batch workers: `model: haiku`, `effort: low`, `maxTurns`, and `isolation: worktree` when parallel workers would collide on files.
- **CONFIRMED [3]**: Non-fork subagents get a **separate prompt cache**; a fork "reuses the parent's prompt cache. This makes forking cheaper than spawning a fresh subagent for tasks that need the same context."
- **CONFIRMED [3]**: Latency counter-argument — prefer the main conversation when "Latency matters — A subagent that isn't a fork starts fresh and may need time to gather context."
- **CONFIRMED [7]**: Cost multiplier data point: "Agent teams use approximately **7x more tokens** than standard sessions when teammates run in plan mode, because each teammate maintains its own context window."
- **CONFIRMED [5]**: Blanket caution: "Running several sessions or subagents at once multiplies token usage."
- **CONFIRMED [11]**: The headline numbers from Anthropic's own production multi-agent system: "agents typically use about **4× more tokens** than chat interactions," and "multi-agent systems use about **15× more tokens** than chats." Token usage alone "explains 80% of the variance" in performance on their benchmark.
- **CONFIRMED [11]**: The cost gate: "multi-agent systems require tasks where the value of the task is high enough to pay for the increased performance." They "excel at valuable tasks that involve heavy parallelization, information that exceeds single context windows," especially "breadth-first queries."
- **CONFIRMED [11]**: The explicit *anti*-fit, and it is directly relevant to a code toolkit: "domains that require all agents to share the same context or involve many dependencies between agents are not a good fit," with coding named as the example because "most coding tasks involve fewer truly parallelizable tasks than research."
- **CONFIRMED [11]**: Task-scoping requirement for each worker: "Each subagent needs an objective, an output format, guidance on the tools and sources to use, and clear task boundaries."

### 4. The three mechanisms the skill is missing

**(a) `/batch <instruction>` — bundled skill [6]**
- **CONFIRMED [6]**: "Researches the codebase, decomposes the work into **5 to 30** independent units, and presents a plan. Once approved, spawns one background subagent per unit in an isolated git worktree. Each subagent implements its unit, runs tests, and opens a pull request. Requires a git repository."
- **CONFIRMED [5]**: It is explicitly "a packaged use of subagents and worktrees, not a separate coordination style."

**(b) Dynamic workflows — the documented answer for large batches [4]**
- **CONFIRMED [4]**: A dynamic workflow is "a JavaScript script that orchestrates subagents at scale. Claude writes the script for the task you describe, and a runtime executes it in the background while your session stays responsive." Named use cases include "a 500-file migration" and "a codebase-wide bug sweep."
- **CONFIRMED [4]**: The per-item primitive is literally a pipeline. From the documented saved-script shape: "`agent()` spawns one subagent and `pipeline()` runs one per item in a list."
- **CONFIRMED [4]**: Why it beats a Claude-orchestrated loop: "A workflow script holds the loop, the branching, and the intermediate results itself, so Claude's context holds only the final answer." Scale row in the comparison table: subagents = "A few delegated tasks per turn"; workflows = "**Dozens to hundreds of agents per run**".
- **CONFIRMED [4]**: Runtime limits — "**Up to 16 concurrent agents**, fewer when Claude Code has fewer CPUs available"; "**1,000 agents total per run**" ("Prevents runaway loops"); no mid-run user input; no filesystem/shell access from the script itself; no module loading.
- **CONFIRMED [4]**: Documented failure semantics — "An `agent()` call resolves to `null` if you stop it mid-run or it hits an unrecoverable API error. `pipeline()` keeps that `null` in the results array, which is why the example ends with `.filter(Boolean)` to drop those entries."
- **CONFIRMED [4]**: Cost guardrails — a `Large workflow` warning fires when a run "schedules more than 25 agents, or its projected token total passes 1.5 million." Size guideline setting maps to agent counts: `small` = fewer than 5, `medium` = fewer than 15 (default), `large` = fewer than 50, `unrestricted` = no guideline.
- **CONFIRMED [4]**: Prompt-cache staggering in fan-out — matching sibling agents are held until the first agent's response begins so they read its cached prefix; hold capped at `CLAUDE_CODE_WORKFLOW_PREFIX_STAGGER_MS`, default `5000` ms.

**(c) `claude -p` loops — the scripted form [2][9]**
- **CONFIRMED [2]**: The documented three-step recipe is: (1) "Have Claude write the list of files that need migrating to a file, so the loop in the next step can read it"; (2) loop `claude -p` over the list; (3) "**Test on a few files, then run at scale** — Refine your prompt based on what goes wrong with the first 2-3 files, then run on the full set."
- **CONFIRMED [2]**: The documented loop, verbatim:
  ```bash
  for file in $(cat files.txt); do
    claude -p "Migrate $file from React to Vue. Return OK or FAIL." \
      --allowedTools "Edit,Bash(git commit *)"
  done
  ```
  Note the two design choices baked in: a **tightly constrained return value** ("Return OK or FAIL") and **`--allowedTools`** scoping, "which matters when you're running unattended."

### 5. How batch size / chunking thresholds should actually be chosen

The skill's item-count bands are the wrong axis. Every threshold I could source is about **context, concurrency, or cost** — never item count.

- **CONFIRMED [2]**: The governing constraint is stated outright: "Most best practices are based on one constraint: Claude's context window fills up fast, and performance degrades as it fills... LLM performance degrades as context fills. When the context window is getting full, Claude may start 'forgetting' earlier instructions or making more mistakes. The context window is the most important resource to manage."
- **CONFIRMED [10]**: The reason to keep one item per call rather than stuffing many items into one prompt: "LLMs generally perform better when each consideration is handled by a separate LLM call."
- **CONFIRMED [4]**: The sourced numeric anchors are: 16 concurrent workflow agents, 1,000 agents per workflow run, 25-agent / 1.5M-token warning line, size guidelines of <5 / <15 / <50.
- **CONFIRMED [3]**: 20 concurrent subagents per session; depth 3.
- **CONFIRMED [6]**: `/batch` decomposes into 5-30 units.
- **CONFIRMED [1]**: Message Batches: 100,000 requests or 256 MB.
- **CONFIRMED [11]**: The one place Anthropic *does* publish complexity tiers is worth studying, because it is shaped exactly like the skill's tiers but scales the **effort**, not the item count. Verbatim, these are rules Anthropic embeds in the lead agent's prompt: "Simple fact-finding requires just 1 agent with 3-10 tool calls"; "direct comparisons might need 2-4 subagents with 10-15 calls each"; "complex research might use more than 10 subagents with clearly divided responsibilities." Also: "the lead agent spins up 3-5 subagents in parallel rather than serially," and subagents "use 3+ tools in parallel," cutting research time "by up to 90%" on complex queries.
- **INFERRED**: A defensible replacement rule for the skill is: *chunk so that (a) each unit's inputs and outputs fit comfortably in one worker's context, (b) concurrent workers stay under the platform cap, and (c) a stop or failure loses at most one unit's work.* Reasoning: each clause maps directly to a Tier-1 constraint above ([2] context degradation, [4]/[3] concurrency caps, [4] resume semantics). Risk if wrong: low — it is strictly more grounded than an arbitrary item-count band.

### 6. Error handling — what actually prevents one failure from losing all progress

This is where the strongest new, non-obvious material is, and where the skill is thinnest.

- **CONFIRMED [4]**: Workflow resume semantics, and they are counter-intuitive: "An agent that was still running when you stopped isn't saved, so it starts over on resume. Replay follows the order agents started. Cached results stop at the first agent that didn't finish, and every agent that started after that one runs again, even if it completed." Worked example from the docs: four agents A-D started in order, stop while B is running → on resume A comes from cache, but B, C **and** D all re-run "even though both completed before you stopped."
- **CONFIRMED [4]**: The design conclusion the docs draw from that: "**A workflow that fans work out across many small agents therefore preserves more progress than one long agent.**" This is the single best-sourced argument for fine-grained item units.
- **CONFIRMED [4]**: Resume is session-scoped — "If you exit Claude Code while a workflow is running, the next session starts the workflow fresh."
- **CONFIRMED [11]**: The governing principle, stated as a section heading: "**Agents are stateful and errors compound.**" Elaborated: "we need to durably execute code and handle errors along the way," because "minor system failures can be catastrophic for agents." Their answer was not to restart: "we built systems that can resume from where the agent was when the errors occurred," pairing model adaptability with "deterministic safeguards like retry logic and regular checkpoints." This is the strongest available Tier-1 endorsement of the skill's accumulate-and-checkpoint instinct — and of the generator's own `/add-checkpoint` skill.
- **CONFIRMED [1]**: Per-request failure isolation is a platform guarantee in the Batches API ("the failure of one request in a batch does not affect the processing of other requests"), and each result carries its own status you can key by `custom_id`.
- **CONFIRMED [9]**: For scripted loops, the durable-progress primitives are: exit code 0 on success / non-zero on failure ("so your scripts can branch on the exit status"); SIGTERM → exit code **143** with the in-flight turn left unfinished and resumable via `--resume`; and `--output-format json` carrying `session_id` and `total_cost_usd` per invocation.
- **CONFIRMED [9]**: Retryable API errors surface as a `system/api_retry` stream event with `attempt`, `max_retries`, `retry_delay_ms`, `error_status`, and an `error` category from a fixed set (`rate_limit`, `overloaded`, `server_error`, `max_output_tokens`, `billing_error`, ...). So retry/backoff is observable, not guesswork.
- **CONFIRMED [9]**: `--bare` "reduce[s] startup time by skipping auto-discovery of hooks, skills, custom commands, subagents, plugins, MCP servers, auto memory, and CLAUDE.md" and is "useful for CI and scripts where you need the same result on every machine" — i.e. it is the mechanism for the skill's own "Maintain consistent processing logic across all items" rule. Docs note it "is the recommended mode for scripted and SDK calls, and will become the default for `-p` in a future release."
- **CONFIRMED [9]**: `--json-schema` with `--output-format json` puts the result in `structured_output` — a mechanical implementation of the skill's "Validate" step, replacing prose validation criteria.
- **CONFIRMED [2]**: For the loop-until-clean variant, the sourced options are a `/goal` condition (re-checked by a separate evaluator after every turn), a `Stop` hook as a deterministic gate ("Claude Code overrides the hook and ends the turn after 8 consecutive blocks"), or an adversarial review subagent.
- **CONFIRMED [4]**: Documented workflow shapes for bounded retry loops, verbatim examples: "run `npx tsc --noEmit` and keep fixing the reported errors until the type check passes **or two rounds in a row make no progress**"; "stop once two rounds in a row find nothing new." Note both use a *no-progress* stopping condition, not a max-iteration count.

### 7. Documented anti-patterns

- **CONFIRMED [2]**: "**The infinite exploration.** You ask Claude to 'investigate' something without scoping it. Claude reads hundreds of files, filling the context. Fix: Scope investigations narrowly or use subagents so the exploration doesn't consume your main context."
- **CONFIRMED [2]**: "**The trust-then-verify gap.** Claude produces a plausible-looking implementation that doesn't handle edge cases. Fix: Always provide verification (tests, scripts, screenshots). If you can't verify it, don't ship it."
- **CONFIRMED [2]**: "**Correcting over and over** ... After two failed corrections, `/clear` and write a better initial prompt incorporating what you learned." This is the sourced version of the skill's "systematic failure → pause" rule, with a much lower threshold than the skill's 20%/50%.
- **CONFIRMED [2]**: Over-review is itself an anti-pattern: "A reviewer prompted to find gaps will usually report some, even when the work is sound, because that is what it was asked to do. Chasing every finding leads to over-engineering."
- **CONFIRMED [10]**: The framing anti-pattern — "find the simplest solution possible, and only increasing complexity when needed," which "might mean not building agentic systems at all"; "optimizing single LLM calls with retrieval and in-context examples is usually enough." Agentic systems "often trade latency and cost for better task performance," and carry "the potential for compounding errors."
- **CONFIRMED [10]**: Loops need explicit stopping conditions — include them "(such as a maximum number of iterations) to maintain control."
- **CONFIRMED [11]**: Over-spawning is a named, observed failure: early versions made mistakes like "spawning 50 subagents for simple queries," hunting endlessly "for nonexistent sources," and "distracting each other with excessive updates."
- **CONFIRMED [11]**: Vague per-item task descriptions cause silent duplication and gaps: "Without detailed task descriptions, agents duplicate work, leave gaps, or fail to find necessary information." Their concrete example: "one subagent explored the 2021 automotive chip crisis while 2 others duplicated work" on 2025 supply chains. Directly relevant to any fan-out where the orchestrator writes each worker's prompt.
- **CONFIRMED [8]**: A quiet but important drift: **`TodoWrite` is disabled by default on current models.** "In Claude Code v2.1.233+, `TodoWrite`, `TaskCreate`, `TaskGet`, `TaskUpdate`, and `TaskList` are not available on Opus 4.8, Sonnet 5, Fable 5, Mythos 5, or later versions of those families unless you opt in," with the stated rationale: "Those models keep track of multi-step work without a written checklist, and the tools' definitions and reminders take up context, so Claude Code leaves them out." Opt in with `CLAUDE_CODE_ENABLE_TODO_TOOLS=1`.

---

## Assessment of `.meta/skills/iterative-processing/`

### CONFIRMED accurate — keep as-is

| What the skill says | Source |
|---|---|
| Process each item with the same logic; consistency is the point | [9] `--bare` exists precisely to make runs reproducible; [10] "LLMs generally perform better when each consideration is handled by a separate LLM call" |
| One item's failure must not halt the batch; log it, continue, report at end | [1] "the failure of one request in a batch does not affect the processing of other requests"; [4] `pipeline()` returns `null` for failed agents and the run continues |
| Distinguish "processing failed" from "validation failed / needs review" | [1] four distinct result types (`succeeded` / `errored` / `canceled` / `expired`) with different billing |
| Retry a failed item once for transient issues | [1] "implement appropriate retry logic for failed requests"; [9] `api_retry` events with `retry_delay_ms` |
| Systematic failure rate should pause the run for guidance | [2] "After two failed corrections, `/clear` and write a better initial prompt"; [10] agents should "pause for human feedback at checkpoints or when encountering blockers" |
| Validate each item's output before accumulating | [9] `--json-schema` / `structured_output`; [2] "Always provide verification... If you can't verify it, don't ship it" |
| Break very large sets into sub-batches | [1] "Consider breaking very large datasets into multiple batches for better manageability" |
| Do NOT use when items have strong dependencies | [10] parallelization applies to "independent subtasks"; [3] fan-out "works best when the research paths don't depend on each other" |
| Account for every item (processed + skipped + errored = total) | [1] `request_counts` does exactly this across the four states |
| Final cumulative review / pattern analysis across items | [4] the documented workflow shape "merge the per-file findings into one ranked summary"; `/deep-research` cross-checks then synthesizes |
| Accumulate durable results as you go rather than only at the end | [11] "Agents are stateful and errors compound"; "we built systems that can resume from where the agent was when the errors occurred" with "retry logic and regular checkpoints" |
| Tiering the pattern by complexity is a legitimate idea | [11] embeds exactly this in its lead-agent prompt — but tiered by workers and tool calls, not item counts (see §5) |

### Unsupported but harmless — leave or soften

- **The four-phase structure** (Initialize / Process Loop / Review / Report). No source names these phases, but nothing contradicts them and they map cleanly onto the documented `/batch` flow (research → decompose → plan → execute → PRs) and the workflow shape (discover list → `pipeline()` per item → synthesize).
- **The "Questions to Ask User" prompt blocks.** Reasonable interaction design, no sourcing needed. One caveat: in `claude -p` and workflow runs these are impossible — [4] "No mid-run user input... For sign-off between stages, run each stage as its own workflow." Worth a one-line note rather than a rewrite.
- **The report template in PROMPTS.md.** Fine. Slightly heavy on emoji/checkmarks and per-item narration; [2]'s own example collapses per-item output to "Return OK or FAIL", which is the opposite instinct. Not wrong, just verbose.
- **"Estimate remaining time"** in progress updates. Harmless but not something an LLM can do reliably; no source supports it.

### Actually wrong or outdated — should change

1. **The provenance line is false.** Three files carry "Source: Based on official Claude Code batch processing patterns and Tool Use best practices" / "Source: Official Claude Code batch processing patterns." No such document exists. "Batch processing" in Anthropic's docs is the Message Batches API [1], which the skill never mentions and does not describe. **Fix**: delete the claim or replace it with the real citations.

2. **The item-count bands are invented, and they scale the wrong variable.** `10-20 simple / 20-100 medium / 100+ complex` in README.md, and `<10 / 10-50 / 50-500 / 500+` in PHASES.md, are not only unsourced — the two files *disagree with each other* about what a "medium batch" is. The instinct to tier by complexity is right: Anthropic does exactly that [11], but tiers by **number of workers and tool calls per worker** ("1 agent with 3-10 tool calls" → "2-4 subagents with 10-15 calls each" → "more than 10 subagents with clearly divided responsibilities"), not by how many items are in the list. **Fix**: keep three tiers, re-cast them on the effort axis, and cite the real platform ceilings (16 concurrent workflow agents, 20 concurrent subagents, 1,000 agents per run, 5-30 `/batch` units, 100,000 requests per Message Batch).

3. **The progress-reporting cadences are invented and now partly counterproductive.** "Report progress every 5 items", "every 10-20 items", "Copy this checklist and update as you work" — no source. And [8] documents that Claude Code now *withholds* the checklist tools on current models because "those models keep track of multi-step work without a written checklist, and the tools' definitions and reminders take up context." **Fix**: keep the idea of durable external progress state (a results file / append-only log the loop can resume from), drop the prescriptive per-N-items cadence and the in-context checklist.

4. **"Very Large Batch (500+ items): break into sub-batches of 100" is a bad default now.** The documented mechanism for a 500-file job is a dynamic workflow with one agent per file [4], not a 100-item sub-batch in one context. And the resume rule [4] says the opposite of what a 100-item sub-batch implies: "A workflow that fans work out across many small agents therefore preserves more progress than one long agent." **Fix**: recommend one unit per item with a bounded concurrency, not large sub-batches in a single context.

5. **The failure-rate thresholds (>20% pause, >50% stop) are made up.** The sourced heuristic is much tighter: two failed corrections on the same problem [2]. **Fix**: keep "pause on a pattern of failures" but drop the false precision, or state plainly that the percentages are a local convention, not a sourced number.

6. **`PROMPTS.md` opens by asking the user four scoping questions before doing anything.** [2]'s recipe is to *do a pilot instead*: "Test on a few files, then run at scale — Refine your prompt based on what goes wrong with the first 2-3 files." **Fix**: replace the interrogation with a pilot-of-3 step.

7. **"Items should be processed in parallel without accumulation (use different orchestration)" is listed as a reason NOT to use this skill.** That exclusion is now backwards: parallel-with-accumulation is exactly what `pipeline()` and `/batch` do. **Fix**: fold parallel execution into the pattern instead of excluding it.

### Missing — should be added

1. **A "choose your mechanism" table.** The single most valuable addition. Roughly:

| Situation | Mechanism | Source |
|---|---|---|
| Many independent LLM calls, no local tools, can wait ≤24h, cost matters | **Message Batches API** — 50% off | [1] |
| Codebase-wide change, git repo, 5-30 units, want PRs | **`/batch`** | [6] |
| Dozens-to-hundreds of items, needs verification, want it rerunnable | **Dynamic workflow** (`pipeline()`) | [4] |
| A handful of items, verbose per-item output you don't want in main context | **Subagent fan-out** (`model: haiku`, `effort: low`, `maxTurns`) | [3] |
| Scripted / CI / reproducible, external item list | **`claude -p` loop** with `--bare` + `--allowedTools` + `--json-schema` | [2][9] |
| Few items, needs back-and-forth | **Main conversation, sequential** | [3] |

2. **The pilot-of-3 rule.** [2], verbatim in effect: refine the prompt on 2-3 items before running the full set. The skill has no equivalent and it is the highest-value cheap safeguard here.

2b. **A per-worker task-spec checklist.** [11]: "Each subagent needs an objective, an output format, guidance on the tools and sources to use, and clear task boundaries" — with the documented consequence of skipping it being duplicated work and silent gaps. The skill's per-item instructions are currently a loose narrative; this turns them into a contract.

2c. **A "don't fan out" gate.** [11] is explicit that "domains that require all agents to share the same context or involve many dependencies between agents are not a good fit," naming coding specifically, and that multi-agent needs "tasks where the value of the task is high enough to pay for the increased performance" at ~15× tokens. The skill currently has a "Do NOT use when" list; this belongs in it.

3. **Blast-radius-driven unit sizing**, with the resume rule [4] as the reason. Currently absent entirely.

4. **Cost awareness.** The skill says nothing about cost. Sourced hooks: agents ≈4× chat and multi-agent ≈15× chat [11]; agent teams ≈7× [7]; fan-out "multiplies token usage" [5]; the 25-agent / 1.5M-token warning line [4]; route workers to Haiku / low effort [3][7]; prompt-cache prefix sharing between sibling agents and the 5s stagger [4]; 50% batch discount [1]; forks share the parent's cache, fresh subagents don't [3].

5. **File-collision guidance for parallel item work.** `isolation: worktree` per worker [3]; `/batch` gives each unit its own worktree [6]; the workflow example phrases it as "working on each file in its own isolated copy" [4]. The current skill assumes a single-threaded loop and never mentions collisions.

6. **Constrained per-item output.** "Return OK or FAIL" [2] and `--json-schema` → `structured_output` [9]. The skill's PROMPTS.md currently encourages a chatty 4-line narration per item, which is the main thing that makes a real batch blow out context.

7. **A no-progress stopping condition** for the iterate-until-clean variant: "two rounds in a row make no progress" [4], plus `/goal` and Stop hooks as gates [2]. The skill has no notion of iterating on the same item set until a check passes.

8. **The interactive-vs-unattended distinction.** Workflows accept "No mid-run user input" [4]; `claude -p` has nobody to prompt [4][9]; permission prompts in unattended runs are a real failure mode ([4] advises adding needed commands to the allowlist before a long run). The skill's user-question-heavy design silently assumes an interactive session.

**Recommendation**: this is a rewrite of README.md and a substantial revision of PHASES.md/PROMPTS.md, not a patch. The abstract loop survives; the numbers, the provenance, and the assumption that "iterative" means "one at a time in one context" do not. Given it is a *reference* pattern that gets copied into generated toolkits, the false-provenance line and the invented thresholds are the two things that must go regardless of how much else gets done.

---

## Trade-offs and Alternatives

**Sequential loop in one context vs. fan-out.** Sequential is simpler, cheaper per item, and keeps full cross-item context for the final review — but it accumulates context and [2] is explicit that "performance degrades as it fills," and [4]'s resume rule means a stop late in a long single-agent run loses everything. Fan-out isolates failures and preserves progress but costs roughly 15× chat tokens [11], gives each worker no cross-item context, and each returned summary still costs main-context tokens [3]. The sourced middle ground: fan out per item with **terse constrained output**, then a single synthesis agent over the collected results [4]. Note the contrarian point that survived review: [11] names coding as a domain that is a *poor* fit for multi-agent because "most coding tasks involve fewer truly parallelizable tasks than research" — so for a code-oriented toolkit, sequential should stay the default and fan-out should be the deliberate exception, not the reverse.

**Claude Code fan-out vs. Message Batches API.** If the per-item work is pure LLM inference over text you already have, the Batches API is strictly better on cost (50% off [1]) and scale (100k requests [1]). If the per-item work needs to read the repo, edit files, run tests, or call your MCP servers, the Batches API cannot do it and Claude Code fan-out is the only option. Mixed case: use the Batches API for the analysis pass and Claude Code for the acting pass.

**Claude-orchestrated loop vs. scripted workflow.** [4] states the trade-off directly: with subagents/skills "Claude is the orchestrator: it decides turn by turn what to spawn or assign next, and every result lands in a context window," whereas a workflow "holds the loop, the branching, and the intermediate results itself, so Claude's context holds only the final answer." Workflows also give repeatability ("What's repeatable: The orchestration itself") and resumability within the session. Cost: they are opaque JavaScript, cap at 16 concurrent / 1,000 total agents, and cannot take mid-run input.

---

## Code / Configuration Reference

Verified verbatim from [2]:
```bash
for file in $(cat files.txt); do
  claude -p "Migrate $file from React to Vue. Return OK or FAIL." \
    --allowedTools "Edit,Bash(git commit *)"
done
```

Verified verbatim from [4] — the shape of a saved dynamic workflow; `pipeline()` is the per-item fan-out primitive:
```javascript
export const meta = {
  name: 'audit-routes',
  description: 'Audit every route handler for missing auth checks',
}

const found = await agent('List every .ts file under src/routes/.', {
  schema: { type: 'object', required: ['files'], properties: { files: { type: 'array', items: { type: 'string' } } } },
})

const audits = await pipeline(found.files, file =>
  agent(`Audit ${file} for missing authentication checks.`, { label: file }),
)

return audits.filter(Boolean)
```
Note `.filter(Boolean)`: [4] states `agent()` resolves to `null` on stop or unrecoverable API error and `pipeline()` keeps the `null` in the results array.

Verified from [9] — structured per-item validation in a scripted loop:
```bash
claude -p "Extract the main function names from auth.py" \
  --output-format json \
  --json-schema '{"type":"object","properties":{"functions":{"type":"array","items":{"type":"string"}}},"required":["functions"]}'
```
Result lands in the `structured_output` field.

Verified from [4] — natural-language prompts that produce a per-item fan-out workflow:
```text
use a workflow to audit every route handler under src/routes/ for missing authentication checks, and adversarially verify each finding before reporting it

use a workflow to migrate every component under src/components/ from styled-components to Tailwind, working on each file in its own isolated copy

use a workflow to run npx tsc --noEmit and keep fixing the reported errors until the type check passes or two rounds in a row make no progress
```

---

## Gaps and Open Questions

- **No empirical accuracy data.** Nothing I fetched quantifies how per-item output quality changes over a long batch (drift, fatigue, prompt-cache-driven anchoring). [2] asserts degradation as context fills but gives no curve. If the rewritten skill wants to claim a batch-size ceiling, that needs a local experiment, not a citation.
- **`/batch`'s 5-30 range is undocumented as to *why*.** Same for the workflow size guidelines' <5 / <15 / <50. These are real, citable numbers but the docs give no rationale, so they should be presented as platform defaults rather than as principles.
- **Non-code batches are underserved by all of this.** Every sourced mechanism assumes files in a git repo or API requests. For consulting-style batches (50 meeting notes, 30 stakeholder interviews, 200 survey responses) the mechanisms still apply but no source demonstrates them. That is the generator's actual primary use case and it is the least-sourced part of this research.
- **Message Batches API cost math for tool-using loops.** The 50% discount applies per token, but a batched agentic request runs "more iterations per turn" than a synchronous one [1] before returning `pause_turn`, so total tokens per item may differ. Net cost for tool-heavy batch items is not something I could source.
- **Not verified empirically**: whether the workflow resume replay rule [4] behaves as documented in practice. It is the load-bearing claim behind the unit-sizing recommendation and it deserves one hands-on test before the skill asserts it.
- **Not fetched**: Anthropic's "Effective context engineering for AI agents" post (https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents), which would add sourced detail on compaction, agent note-taking / external memory as a long-horizon pattern, and attention degradation as context grows. The claims in this file that it would corroborate ([2] on context degradation, [11] on checkpointing) already stand on their own Tier-1 sources, so this is a depth gap rather than a soundness gap. Worth one WebFetch if the rewrite wants a stronger "why external progress state beats an in-context checklist" argument.
- **Not searched**: practitioner reports (GitHub issues, HN, engineering blogs) on `claude -p` loops at scale, `/batch` in real use, and progress lost mid-batch. Everything here is vendor documentation, which means the failure modes are the ones Anthropic chose to document, not necessarily the ones users actually hit. Treat the cost and concurrency numbers as reliable and the "this works well" framing as unaudited.

---

## Contradictions with Prior Knowledge

- The TODO entry says "the skill reads as solid and is not blocking anything." That holds for the *abstract loop*, but not for the file as written: the provenance claim is false, the two files' item-count bands contradict each other, and the "500+ → sub-batches of 100" advice is now the opposite of the documented approach. The skill's priority is correctly low, but its scope of change is larger than "enrich with sourced examples."
- `.meta/AGENTIC-PATTERNS.md` documents subagents as "the current recommended pattern for scoped agents" but does not connect them to batch/iterative work. The two files are consistent, just disconnected — the fan-out material from this research belongs in whichever one survives, not both.
- `.meta/PHASES-GUIDE.md` cites iterative-processing as the exemplar for "why a skill needs a PHASES.md." If the skill is rewritten, that reference needs a look.

---

## Sources

[1] Batch processing (Message Batches API) — https://platform.claude.com/docs/en/build-with-claude/batch-processing
[2] Best practices for Claude Code — https://code.claude.com/docs/en/best-practices
[3] Create custom subagents — https://code.claude.com/docs/en/sub-agents
[4] Orchestrate subagents at scale with dynamic workflows — https://code.claude.com/docs/en/workflows
[5] Run agents in parallel — https://code.claude.com/docs/en/agents
[6] Slash commands (`/batch`, `/goal`, `/loop`, `/code-review`) — https://code.claude.com/docs/en/commands
[7] Manage costs effectively — https://code.claude.com/docs/en/costs
[8] Tools reference (`TodoWrite`, `Agent`) — https://code.claude.com/docs/en/tools-reference
[9] Run Claude Code programmatically — https://code.claude.com/docs/en/headless
[10] Building effective agents (Anthropic Engineering) — https://www.anthropic.com/engineering/building-effective-agents
[11] How we built our multi-agent research system (Anthropic Engineering) — https://www.anthropic.com/engineering/multi-agent-research-system
