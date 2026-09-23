# Claude Model Tier Capability Boundaries — Research Reference

**Research date**: 2026-08-21
**Confidence**: Medium-High overall. **High** on official positioning, pricing, context windows, platform constraints, and Anthropic's own measured benchmark results (an unusually well-documented primary source exists). **Medium** on "where tier X fails" as a task-category statement — Anthropic publishes measured *accuracy gaps*, not failure modes, so most failure-boundary claims are inferred from those gaps; and **Medium** on the community patterns, which are well-corroborated on HN but Reddit was entirely inaccessible, biasing the sample toward the cost-conscious/contrarian view. **Low** on anything labelled single-anecdote, and on the central contrarian thesis, which is well-argued from several directions but has never been isolated in a published experiment.
**TODO reference**: `TODO.md` → "Promote MODEL-BEHAVIOR-RULES.md to AI-BEHAVIOR-GUIDELINES.md"; `TODO.md` → "Verify Bedrock/model claims from Gemini research session" (model tier research)
**Purpose**: Validate or correct `.meta/MODEL-BEHAVIOR-RULES.md` — currently a stub written from assumptions — so the generator can tell Claude how to behave based on its running tier, and tell users which model to pick for which task.

---

## Key Finding

**The tier map in `MODEL-BEHAVIOR-RULES.md` is directionally right about ordering and wrong about the two things that matter most: (a) the *effort* parameter, not the model tier, is the primary quality/cost dial on every current model except Haiku, and Anthropic's own measurements repeatedly show a single model at lower effort beating a multi-model architecture; and (b) the rule "Opus plans, Sonnet executes" is contradicted by Opus 5's documented capability set — Anthropic explicitly lists "completing multi-file features, larger refactors, and end-to-end feature work *without leaving stubs or placeholders*" as an Opus 5 capability gain [6], which is the opposite of the stub's instruction that Opus should scaffold with TODOs and hand off.**

A second correction of equal practical weight: the model lineup in the repo's `.meta/` files is stale. The current tiers are **Haiku 4.5 → Sonnet 5 → Opus 5 → Fable 5**, with Opus 4.8 now classed as a legacy model [2].

---

## Findings

### 1. Current tier map and official positioning (Q1)

- **CONFIRMED [2]**: The current lineup, lowest to highest cost and capability, is Claude Haiku 4.5, Claude Sonnet 5, Claude Opus 5, Claude Fable 5. Opus 4.8, Opus 4.7, Opus 4.6, Sonnet 4.6, Sonnet 4.5, and Opus 4.5 are listed under "Legacy models."
- **CONFIRMED [2][12]**: Specs and prices as of this research date:

| | Fable 5 | Opus 5 | Sonnet 5 | Haiku 4.5 |
|---|---|---|---|---|
| Official description | "Next-generation intelligence for long-running agents" | "For complex agentic coding and enterprise work" | "The best combination of speed and intelligence" | "The fastest model with near-frontier intelligence" |
| Context | 1M | 1M | 1M | **200K** |
| Max output (sync) | 128K | 128K | 128K | **64K** |
| Input / output per MTok | $10 / $50 | $5 / $25 | $2 / $10 | $1 / $5 |
| Cache read per MTok | $1.00 | $0.50 | $0.20 | $0.10 |
| Comparative latency | **Slower** | Moderate | Fast | Fastest |
| Adaptive thinking | Yes (always on, cannot disable) | Yes (on by default) | Yes (on by default) | **No** |
| `effort` parameter | Yes (low–max) | Yes (low–max) | Yes (low–max) | **Not supported** |
| Reliable knowledge cutoff | Jan 2026 | May 2026 | Jan 2026 | **Feb 2025** |

- **CONFIRMED [12]**: Sonnet 5's $2/$10 pricing, originally announced as introductory through 2026-08-31, **is now the standard price**; the scheduled increase to $3/$15 will not occur. (This corrects the bundled `claude-api` skill's cached table, which still shows $3 with an intro rate.)
- **CONFIRMED [1]**: Anthropic's model selection matrix — Fable 5 for "the highest available capability… long-running agents, deep reasoning, long-horizon agentic tasks, advanced research"; Opus 5 for "multihour autonomous coding agents, large-scale refactoring, complex systems engineering, advanced research, knowledge work, vision-heavy workflows, computer use"; Sonnet 5 for "code generation, data analysis, content creation, visual understanding, agentic tool use"; Haiku 4.5 for "real-time applications, high-volume intelligent processing, cost-sensitive deployments needing strong reasoning, **sub-agent tasks**."
- **CONFIRMED [1]**: Anthropic offers **two** starting strategies, not one. "Option 1: Start efficiency-first" — *begin implementation with Claude Haiku 4.5*, test, and "upgrade only if necessary for specific capability gaps." "Option 2: Start capability-first" — begin with Opus 5 and optimize down. This is materially different from the repo's current "default to Sonnet" framing.
- **CONFIRMED [1]**: On which dial to reach for first: *"Tuning effort is often a better lever than switching models."*
- **CONFIRMED [12]**: The pricing page's own summary heuristic is the simple one: "Choose Haiku for simple tasks, Sonnet for most production workloads, and Opus for the most complex reasoning."

### 2. What benchmark differences actually predict (Q2)

Anthropic published an unusually detailed, self-critical measurement page [3] with cost-per-completed-task figures. All figures below are Anthropic-internal runs from July–August 2026 at then-current list prices, described by Anthropic as "directional, not guarantees."

- **CONFIRMED [3]**: Per-token price is a poor predictor of per-task cost. "A more capable model finishes a task with less work: fewer turns, less searching, less re-reading of its own context, and less backtracking. The per-token premium is routinely overwhelmed by doing less of everything."
- **CONFIRMED [3]**: On DeepResearch Bench II, **Fable 5 at `low` effort was more accurate and about 10% cheaper per task than Sonnet 5** — the frontier model was outright cheaper than the mid-tier one.
- **CONFIRMED [3]**: But it reverses by workload. On Anthropic's SWE-bench Pro subset, **Opus 5 alone matched Fable 5 alone (91.7% vs 91.3%, inside run-to-run noise) at about 60% of its cost.**
- **CONFIRMED [3]**: On an internal 370-task agentic-coding benchmark, Opus 5 alone at default effort scored 84.4% for $8.50/attempt; Fable 5 alone at `medium` scored 83.4% for $8.20. **Fable is not the better coding model at equal spend.**
- **CONFIRMED [3]**: The recommended default is explicit: *"For most agent workloads, start with Claude Opus 5."*
- **CONFIRMED [3]**: How to read benchmarks for your own use — *"Price the tail of your workload, not the median: compare models on the hardest tenth of your tasks, not the typical one. On the typical task every model looks similar and the cheapest looks best, but the bill is decided by the tasks the cheaper model fails."* On a 20-problem WideSearch run, **two problems carried 43% of total spend.**
- **INFERRED**: Benchmark deltas predict *tail* behavior, not median behavior. Reasoning: Anthropic's own framing above, plus the observation that Opus 5 and Fable 5 were statistically indistinguishable on a benchmark both "largely saturate." Risk if wrong: a toolkit that recommends tiers by average task difficulty will systematically under-provision on the 10% of tasks that decide the outcome and the bill.

### 3. Where Haiku genuinely fails that Sonnet succeeds (Q3)

This is the best-evidenced failure boundary in the research, because Anthropic measured it directly.

- **CONFIRMED [3]**: *"Claude Haiku 4.5 answered GPQA Diamond questions at about a tenth of Opus 5's cost per question, with **63% accuracy compared with 92% for Opus**, and **fell much further behind on long coding tasks**. It fits high-volume work with checkable outputs, not long agentic loops."* This is the single most quotable tier boundary available: a **29-point** gap on graduate-level reasoning, and a larger (unquantified) gap on long-horizon coding.
- **CONFIRMED [3]**: In the advisor measurements, *"a Claude Haiku 4.5 executor gained a great deal from a Claude Opus 5 advisor, a Claude Sonnet 5 executor gained a few points, and a frontier executor almost nothing."* The size of the advisor's gain is a proxy for the capability the executor lacks — Haiku's gap is large, Sonnet's is small.
- **CONFIRMED [8]**: **Claude Code refuses to plan on Haiku.** "A Haiku session that would normally upgrade to Sonnet in plan mode likewise uses the newest permitted Sonnet, and stays on Haiku only when every Sonnet is excluded." Anthropic's own harness treats Haiku as unfit for plan-mode reasoning. This is strong first-party corroboration of the stub's "do not design or plan anything architectural" rule.
- **CONFIRMED [11]**: **Haiku cannot act as an advisor** — "Haiku can call the advisor but cannot act as one." It is the only tier with this restriction.
- **CONFIRMED [2][4][8]**: **Haiku 4.5 does not support adaptive thinking and does not support the `effort` parameter.** Claude Code's effort table lists Fable 5, Opus 5/4.8/4.7, Sonnet 5, Opus 4.6, Sonnet 4.6 — and states "Models not listed here do not support effort." Practical consequence: *on Haiku there is no quality dial.* Every other tier can be tuned; Haiku is take-it-or-leave-it (its only thinking control is the legacy `thinking: {type: "enabled", budget_tokens: N}` path [2]).
- **CONFIRMED [2]**: **Haiku 4.5's reliable knowledge cutoff is February 2025** — roughly 18 months stale as of this research date, versus May 2026 for Opus 5. This is an underappreciated, concrete failure mode distinct from reasoning capacity: Haiku will confidently give outdated answers about libraries, APIs, and pricing.
- **CONFIRMED [13]**: Anthropic's own positioning for Haiku is explicitly delegated/parallel: the Haiku 4.5 launch describes a larger model decomposing a hard problem into a plan, then orchestrating "a team of multiple Haiku 4.5s to complete subtasks in parallel."
- **CONFIRMED [13]** (third-party, quoted by Anthropic — treat as vendor-selected): Augment reported Haiku 4.5 "achieves 90% of Sonnet 4.5's performance" on their agentic coding eval; Gamma reported 65% vs 44% accuracy against their prior premium-tier model on slide-text instruction following.
- **INFERRED**: The Haiku boundary is **task horizon and verifiability**, not task "simplicity." Reasoning: Anthropic's phrasing is "high-volume work with checkable outputs, not long agentic loops" [3] — the discriminator is whether output can be checked and whether the loop is short, not whether the task sounds easy. Risk if wrong: the stub's current framing ("simple, well-scoped, high-volume") will pass tasks to Haiku that are individually simple but arrive as a 40-turn loop, where it degrades sharply.

**Correction to the stub**: the stub's "work with codebases larger than ~50K tokens without chunking" limit is not supported by anything found. Haiku's documented limit is a **200K context window** [2], and in Claude Code a subagent's window is sized by *its own* model, so delegating to Haiku hands that subagent a 200K window [10].

### 4. Where Sonnet genuinely falls short of Opus (Q4)

Weaker evidence than the Haiku boundary. Anthropic does not publish a head-to-head Sonnet 5 vs Opus 5 benchmark table; the gap has to be reconstructed.

- **CONFIRMED [3]**: On **DeepSWE** (113 original long-horizon engineering tasks, five languages, program-verified), a low-effort **Sonnet 5 executor paired with a stronger advisor gained 23 points.** That 23-point recoverable gap is the clearest quantification of what Sonnet 5 lacks on long-horizon original coding work.
- **CONFIRMED [3]**: On GPQA Diamond, by contrast, a Sonnet 5 executor "gained a few points" from an Opus 5 advisor. **The Sonnet→Opus gap is workload-shaped: small on knowledge Q&A, large on long-horizon coding.**
- **CONFIRMED [7]**: Anthropic's own framing of where Sonnet 5 sits: it "is also an option for workloads that need more capability than Claude Sonnet 4.6 provides *without moving to an Opus-class model*" — i.e. Sonnet 5 is positioned as the ceiling-avoidance option, not the ceiling.
- **CONFIRMED [6]**: Opus 5's documented capability gains over Opus 4.8, which by extension describe what the Opus tier is for: deep reasoning across long problem chains; **agentic coding and long-horizon tasks, "staying on task across extended tool-use loops and completing multi-file features, larger refactors, and end-to-end feature work without leaving stubs or placeholders"**; test-time compute scaling; code review and bug-finding "at a high rate per pass with few false positives"; vision; long-context work with "consistent instruction following, tool calling, and reasoning throughout the window"; office/document generation; **multi-agent coordination** with "effective writer-verifier patterns and few cases of agents overwriting each other's work."
- **CONFIRMED [3][6]**: **Structural (not just quality) limits on Sonnet 5**: task budgets — the advisory token countdown that lets a model self-regulate on long agentic loops — are available on Opus 5, Fable 5, Opus 4.8, and Opus 4.7 but **not on Sonnet 5**. Sonnet 5 also has no Priority Tier [7], and (per the bundled API skill [14]) does not support mid-conversation system messages, which Opus 5/4.8 and Fable 5 do.
- **CONFIRMED [9]**: The Claude Code blog's working analogy, which is the most useful practical framing found: **Opus at low effort** is like "five minutes with an expert who has deep experience with problems like yours" — brings pattern recognition your codebase doesn't contain, but only skims your code. **Sonnet at high effort** is like handing a strong generalist an afternoon — it reads everything, runs things, verifies, and ends up understanding *your specific code* thoroughly, but brings less prior recognition.
- **CONFIRMED [9]**: The diagnostic for choosing between them: ask whether Claude *"did it not **try** hard enough, or did it not **know** enough?"* Context + visible effort + a wrong answer → upgrade the model. Skipped files or unrun tests → upgrade the effort. And: a bigger model helps specifically where a smaller one is "confidently wrong no matter how much context you give it."
- **CONFIRMED [9]**: Ambiguity tolerance is the other axis — larger models "handle ambiguity better, while smaller models do best with specific instructions directing execution."
- **INFERRED**: Sonnet 5's shortfall is concentrated in (a) sustained multi-hour autonomous loops, (b) novel problems with no in-repo precedent, and (c) ambiguous/underspecified briefs. Reasoning: the DeepSWE 23-point advisor gain, the "confidently wrong regardless of context" signal, and the explicit ambiguity statement all point the same way. Risk if wrong: teams keep Sonnet on multi-day autonomous work and pay in silent quality loss rather than visible failure.

**Correction to the stub**: the stub tells Sonnet not to "write extensive architectural documentation as the primary deliverable" and not to "produce comprehensive PRD, epic, and story sets." Nothing in the sources supports a *document-type* restriction on Sonnet. The supported restriction is about *problem novelty, ambiguity, and horizon length* — not deliverable format.

### 5. What Fable is positioned for that Opus is not (Q5)

- **CONFIRMED [5]**: Fable 5 is "Anthropic's most capable widely released model, built for the most demanding reasoning and **long-horizon agentic work**." GA since 2026-06-09.
- **CONFIRMED [8]**: In Claude Code specifically: Fable 5 is "the most capable model in Claude Code, **suited to tasks larger than a single sitting**. It sustains long autonomous sessions, **investigates before acting**, and **verifies its work more often than smaller models**." Fable is not the default on any account type; it must be explicitly selected.
- **CONFIRMED [8]**: How to prompt it differently — *"Describe the outcome, not the steps: hand it the result you want and let it plan the path."* / *"Hand it ambiguous problems: root-cause investigations, outage debugging, and architecture decisions."* / **"Skip the verification reminders: it verifies its own work with less prompting, so reminders to test or check are usually unnecessary."**
- **CONFIRMED [9]**: On long multi-step work "it pulls furthest ahead," and in Anthropic's testing **"it finished jobs Opus and Sonnet can't reach at any effort level."** This is the strongest available statement that Fable occupies a genuinely different capability regime rather than just a higher price point — and note the qualifier *at any effort level*, which is the one place Anthropic says effort tuning cannot substitute for a tier change.
- **CONFIRMED [4]**: *"Lower effort settings on Claude Fable 5 still perform well and often exceed `xhigh` performance on prior models."* Practical: Fable at `low`/`medium` is often the right way to buy Fable, not Fable at `max`.
- **CONFIRMED [11]**: Tier ranking is enforced in code — **Fable 5's only accepted advisor is Fable**; an Opus or Sonnet advisor is rejected. Opus 4.7+ models are ranked equally capable to one another; Sonnet 5 and Opus 4.6 are ranked equally capable.

**Fable's concrete costs and constraints — the part the stub omits entirely:**

- **CONFIRMED [2]**: Comparative latency is **"Slower"** — the only current model so labelled. On Anthropic's 21.6M-token corpus benchmark, a solo Fable 5 episode took **7.9, 9.1, and 11.4 hours** at `low`, `medium`, and default effort [3].
- **CONFIRMED [5]**: **Fable 5 carries 30-day data retention and is NOT available under zero data retention.** It is a designated Covered Model. For consulting engagements under a ZDR agreement, Fable is simply unavailable — and in Claude Code under ZDR the `/model` picker omits or disables it [8].
- **CONFIRMED [5]**: Fable 5 includes **safety classifiers that can decline requests** (returned as HTTP 200 with `stop_reason: "refusal"`, most often in cybersecurity and biology domains [8]). Integrations need refusal handling and a fallback path. Opus 5 does not carry these classifiers; Sonnet 5 does have real-time cyber safeguards [7].
- **CONFIRMED [2]**: Fable 5 uses the Opus 4.7-generation tokenizer — **the same text produces roughly 30% more tokens** than on pre-4.7 models, so its 1M window holds less text than the number suggests.
- **CONFIRMED [8]**: On many plans Fable usage bills to **usage credits** rather than plan limits, with a one-time interactive consent prompt. In headless/`-p`/Agent SDK runs the prompt never appears and the request bills without asking — a real cost surprise for automated toolkits.
- **CONFIRMED [3]**: Fable 5 is more sensitive to a low `max_tokens` than Opus: a 16,384-token cap ended **15% of Opus 5's attempts and a third of Fable 5's**, none of them solved.
- **CONFIRMED [11]**: The advisor tool — the cheapest way to get Fable-class judgment — is **not available on Amazon Bedrock, Claude Platform on AWS, Google Cloud, or Microsoft Foundry.** Anthropic API only.

**INFERRED**: The stub's claim that Fable differs from Opus only in "scope and duration, not output type" is roughly defensible but incomplete. The differences that matter operationally are latency (hours, not minutes), ZDR ineligibility, refusal handling, and the credits-billing surprise. Risk if wrong: a generated toolkit recommends Fable to a client engagement that cannot legally use it, or an unattended agent quietly burns usage credits.

### 6. Practitioner reports (Q6)

See "Community and Practitioner Evidence" below. **This is the weakest section of the research** and is flagged accordingly.

### 7. Context window differences, practically (Q7)

- **CONFIRMED [2]**: Haiku 4.5 = 200K context / 64K max output. Fable 5, Opus 5, Sonnet 5 = 1M context / 128K max output. On the Batch API, Opus 5/4.8/4.7/4.6, Sonnet 5, and Sonnet 4.6 support up to **300K output tokens** with the `output-300k-2026-03-24` beta header.
- **CONFIRMED [12]**: **There is no long-context surcharge.** "Claude 4.6 and later models… include the full 1M token context window at standard pricing. (A 900k-token request is billed at the same per-token rate as a 9k-token request.)" Prompt caching and batch discounts apply at standard rates across the full window. Claude Code's docs say the same [8].
- **CONFIRMED [8]**: **On Amazon Bedrock, Google Cloud's Agent Platform, and Microsoft Foundry, Opus 4.8 and Opus 5 run with a 200K context window**, and Claude Code auto-compacts them at the 200K boundary. On the Anthropic API, Fable 5, Sonnet 5, and Opus 4.7+ always run at 1M. **This is the single most important practical fact for anyone running this toolkit through Bedrock**: your Opus context window is a fifth of what the model docs advertise.
- **CONFIRMED [8]**: Sonnet 5 on the Anthropic API has no 200K variant and no `[1m]` suffix; sessions auto-compact at about **967K tokens** by default. `CLAUDE_CODE_DISABLE_1M_CONTEXT=1` forces every native-1M model down to a 200K budget.
- **CONFIRMED [10]**: **A subagent's context window is sized by its own model, not the parent's.** Delegating to Haiku gives that subagent a 200K window regardless of the main session's model.
- **CONFIRMED [2][7]**: Tokenizer inflation is the hidden context tax. Claude 4.7-and-later models (including Fable 5) and Sonnet 5 produce ~30% more tokens for the same text than Sonnet 4.6-and-earlier. Token counts, `max_tokens` budgets, and effective window capacity must all be re-baselined per model, not carried over.
- **CONFIRMED [3]**: The genuine context-window boundary is where delegation becomes the only option. On a **21.6M-token** corpus (14 Python packages, 130 planted defects, larger than any context window), lowering effort could not help — "the bill is the corpus read itself: Claude Fable 5 solo cost $720 to $764 per episode at every effort setting, and only its accuracy moved." A Fable 5 coordinator with 25 concurrent Sonnet 5 workers cost **>60% less** and scored 2–6 points below Fable's best. Wall clock: ~2 hours vs 11.4 hours solo.
- **CONFIRMED [3]**: But — *"Reading-heavy work that still fits in one context window is a model-choice problem, not a delegation problem."*

### 8. Documented tier-mismatch and architecture-mismatch failures (Q8)

Anthropic documents several of these directly, which is unusual and worth exploiting.

- **CONFIRMED [3]** — *too-small a model:* Haiku 4.5 at 63% vs Opus 5 at 92% on GPQA Diamond, and "fell much further behind on long coding tasks."
- **CONFIRMED [3]** — *wasting a large model via stale prompts:* On a support-desk evaluation, **prompts written for Claude Opus 4.8 cost 36% more per ticket on Claude Opus 5 for no change in accuracy.** Auditing the same prompts made Opus 5 both 14% cheaper *and* more accurate (97% of tickets, up from 92%). Removing "verify twice" alone cut Opus 5's cost per ticket **by a third**; removing "be maximally thorough" almost as much. A retired thinking setting, contradictory rules, and a hand-rolled scratchpad each restored **7 to 11 accuracy points** when removed.
- **CONFIRMED [6]** — *the same trap, restated for Opus 5:* "It also verifies its own work without being told to, so **remove verification instructions carried over from earlier models** ('include a final verification step,' 'use a subagent to verify'); they cause over-verification on Claude Opus 5."
- **CONFIRMED [3]** — *architecture mismatch (advisor):* "An executor at low effort can stop noticing it is stuck: a pairing that consults on most tasks at the default effort can fall to consulting on almost none when effort is lowered, **and then scores below the executor alone**." On DeepSWE a low-effort Sonnet 5 executor kept asking and gained 23 points; on SWE-bench Pro the same executor stopped asking. **Same models, same configuration, opposite outcome, decided by the consult rate.**
- **CONFIRMED [3]** — *architecture mismatch (orchestrator):* "When the work is one dependent chain, or fits in a single context, the orchestrator pays for a plan, a handoff, and a merge that a single model gets for free. **In every such case measured, the coordinator's model alone at lower effort came out ahead.**" On the full, harder BrowseComp set "the frontier model alone reached the coordinator configuration's accuracy at 22% to 30% lower cost."
- **CONFIRMED [3]** — *the counter-intuitive one:* delegation to cheap workers paid off **on the routine, normally-solvable share of work**, as insurance against a frontier model occasionally spiralling on an easy problem — "the opposite of the intuition that workers are for hard problems." A Fable 5 coordinator with one Sonnet 5 worker cost under half of Fable alone on average and a third at p90 ($12 vs $33); the solo model's single most expensive run, at $84, was also wrong.
- **CONFIRMED [3]** — *config mismatch masquerading as tier mismatch:* a 16,384-token `max_tokens` cap ended 15% of Opus 5's and a third of Fable 5's attempts, none solved. `max_tokens` "caps a single response, invisibly to the model, so lowering it does not make the model economize." Raising to 64,000 took Fable from 36.6% to 54.6% solved on the problems both runs scored. **Recommendation: `max_tokens` 64,000 for agentic work, 128,000 at `xhigh`/`max` effort, and treat `stop_reason: max_tokens` as a failure.**

---

## Trade-offs and Alternatives

### The dial hierarchy (this is the actionable conclusion)

Anthropic's measured ordering of cost/quality levers [3], strongest first:

1. **Prompt caching** — "the largest lever by a wide margin": cut agent-loop cost by a factor of **2.5–3.7**; cut a triage agent's bill by **83%** (88% with input trimming). Quality cost: none. *Worth more than most model-choice decisions.*
2. **Prompt audit against the model you are actually running** — 14% cheaper at equal-or-better accuracy on both migrations measured. Quality cost: none; a gain on one.
3. **Batch API** — flat 50% off, for anything nobody is waiting on.
4. **Effort tuning** — knowledge work: `medium` matched the default's accuracy at 70–85% of cost, `low` gave up 1–3 points for a third to a half off; long coding: `medium` ≈ half the cost for ~2 points, `low` ≈ a quarter the cost for ~8 points.
5. **Re-run failures at higher effort** (only where outcomes are checkable) — Opus 5 at `low` with failures re-run at default: ~93% pass for ~$0.70/task vs 91.7% for $1.39 running everything at default. **Same pass rate, half the cost.**
6. **Model choice** — real, but ranked *below* all of the above.
7. **Multi-model architecture** — narrowest, most fragile, and easiest to get wrong.

**Anthropic's explicit warning [3]**: *"draw this curve for your own workload before you add a second model: in these internal measurements, a multi-model configuration that looked cheaper than the default single model cost more than that same model at lower effort."* And on DeepWideSearch, Fable 5 at `low` effort "matched an orchestrator with a Claude Sonnet 5 worker at 20% lower cost: **lowering effort beat an architecture change.**"

### Where effort *cannot* substitute for a tier change

Three documented exceptions, and they bound the whole argument:

1. **CONFIRMED [9]**: Fable "finished jobs Opus and Sonnet can't reach at any effort level."
2. **CONFIRMED [3]**: Work larger than one context window — "Lowering effort cannot help, because the bill is the corpus read itself."
3. **CONFIRMED [3]**: Workloads that reach the model's ceiling — on DeepResearch Bench II "every effort step bought about 2.4 points of rubric score; there is no free cost cut on that curve."
4. **CONFIRMED [4][8]**: Haiku has no effort parameter at all, so on Haiku the only dial *is* the model.

### Four ways to combine tiers, ranked by how well they hold up

| Approach | Mechanism | Evidence quality | Verdict |
|---|---|---|---|
| **Advisor tool** [11] | Stronger model consulted mid-task at decision points; **does not invalidate the main model's prompt cache** | Measured; outcome swings entirely on consult rate | Best-evidenced way to buy a higher tier's judgment cheaply — *if* you measure the consult rate |
| **`opusplan`** [8] | Claude Code alias: Opus during plan mode, auto-switches to Sonnet for execution | First-party feature; no published measurement | Validates the repo's "Big Model Plans, Small Model Executes" pattern as a shipped feature, but note it switches *mid-session*, which does invalidate cache |
| **Subagents with pinned models** [10] | Delegate a whole subtask to a cheaper (or costlier) tier | First-party; measured in the orchestrator studies | Works for genuinely independent fan-out; loses to single-model-at-lower-effort otherwise |
| **Orchestrator / coordinator** [3] | Frontier plans and merges, cheap workers do the bulk | Heavily measured | Pays in exactly two situations: work larger than one context window, and routine work with a long cost tail |

**Notable**: the advisor is the only one of the four that doesn't break the cache. `/advisor` toggling mid-session preserves the cached prefix, whereas "changing model or effort level" does not [11]. That is a stronger argument for advisor-over-model-switching than anything in the repo's current guidance.

### Claude Code operational specifics worth baking into a toolkit

- **CONFIRMED [8]**: Model aliases: `default`, `best` (Fable where available, else latest Opus), `fable`, `opus`, `sonnet`, `haiku`, `sonnet[1m]`, `opus[1m]`, `opusplan`. `ANTHROPIC_DEFAULT_{OPUS,SONNET,HAIKU,FABLE}_MODEL` control alias resolution; `availableModels` + `enforceAvailableModels` restrict the picker. **Haiku models are always available and cannot be disabled at the org level**, so every user keeps at least one usable model.
- **CONFIRMED [8]**: Organization admins on Enterprise plans can cap the **maximum effort level per model per role**. A toolkit that assumes `xhigh` is available may be silently clamped.
- **CONFIRMED [10]**: Subagent model resolution order: `CLAUDE_CODE_SUBAGENT_MODEL` env var → per-invocation `model` param → subagent frontmatter → main conversation's model. Omitting `model` means `inherit`.
- **CONFIRMED [10]**: As of Claude Code v2.1.198 the built-in **Explore** subagent inherits the session model instead of always running Haiku, capped at Opus on the Anthropic API. To force cheap exploration you must shadow it with a project subagent named `Explore` carrying `model: haiku`.
- **CONFIRMED [10]**: **Forks reuse the parent's prompt cache** ("its first request reuses the parent's prompt cache… cheaper than spawning a fresh subagent for tasks that need the same context"); non-fork subagents get a separate cache. Relevant to any generated agent architecture.
- **CONFIRMED [11]**: Accepted advisor pairings — Haiku main: Fable/Opus/Sonnet. Sonnet 5 main: Fable/Opus/Sonnet 5 (a Sonnet 4.6 advisor is rejected). Opus 4.7+ main: Fable, or Opus 4.7+. Fable main: Fable only.

---

## Community and Practitioner Evidence

**Confidence: Medium on the corroborated patterns below, Low on everything labelled single-anecdote.**

**Coverage limit, stated up front**: Reddit was **completely inaccessible** in this research (r/ClaudeAI, r/ClaudeCode, old.reddit, proxy and mirror all blocked or 403); DuckDuckGo and Mojeek served CAPTCHAs/403. The community evidence below is therefore **Hacker News (via the Algolia API), engineering blogs, GitHub issues, and two vendor/self-published benchmarks**. Reddit claims appear only as secondhand relay and are marked as such. **Do not read this as neutral**: HN skews more API/cost-conscious and more open-weights-friendly than Reddit does, which biases the sample *toward* the contrarian position.

**Reading caveat that changes how the whole Fable corpus should be interpreted**: Fable 5 shipped 2026-06-09, **about six weeks before Opus 5** (2026-07-24). Most "Fable vs Opus" practitioner discussion therefore compares Fable against **Opus 4.8**, not Opus 5 — which is exactly the comparison Anthropic's own measurements say Opus 5 changed [6].

### Corroborated patterns (weight these)

- **CORROBORATED [15]** — *Haiku 4.5 is genuinely good enough for scoped explore/fan-out/retrieval subagent work.* **15+ independent HN practitioners over Dec 2025–Aug 2026, with no dissent on the scoped case.** The load-bearing qualifier every one of them attaches is *narrow scope / well-defined task*. Representative: "plan w/ opus, spawn subagents w/ haiku… scoped properly, they'll do it just fine"; "low hallucination rate, so it is great for exploration tasks"; "you don't need Opus to decide if a note is contextually relevant." Structurally corroborated by Claude Code's own design [10]. **This is the strongest community finding in the research and it directly supports the stub's Haiku section.**
- **CORROBORATED [15]** — *Haiku degrades on judgment, complex structured outputs, and unscoped work* (~7 sources). Notably, the **dominant** Haiku criticism on HN is now **staleness**, not weakness: "came out nearly a year ago, and it's showing its age." This independently corroborates the Feb 2025 knowledge-cutoff finding [2] as the practical limiter.
- **CORROBORATED [15][22]** — *Switching model or effort mid-session carries a real cost/quality penalty.* Anthropic's own "Maximizing the value of your Claude Code sessions" post warns about it; practitioners supplied the mechanism independently (prefix-match caching — "no prefix which can be cached," so the whole thing is reprocessed); and Manifest reached the same conclusion from operating a router [18]. **Official guidance + independent mechanism + independent operational experience from a different company** — one of the best-supported findings here, and it corroborates the cache-invalidation logic already in `BEDROCK-COST-GUIDE.md`.
- **CORROBORATED [15]** — *Big-model-plans / small-model-executes works in practice* (4–5 sources): "much better results with this than with straight up Opus throughout," plus hitting usage limits less often. **One substantive architectural dissent** (see below) and one cost complaint about `/model opusplan` specifically.
- **CORROBORATED [15]** — *Fable 5 is overkill for routine work* (9+ independent sources, several using that exact word). Includes a self-reported case of firing trivial errands at premium models "way overkill for fable or even opus." Three independent anecdotes converge on the same failure shape: **Fable over-validates and over-spends below its level** — "spent 20% of the time on coding and 80% on validation"; "burned through an exponential amount of tokens to complete a simple task."
- **CORROBORATED [15]** — *Fable 5 nonetheless wins on autonomous long-horizon and cross-boundary discovery* (8+ sources): finishing an end-to-end low-level systems project where Opus stalled on architecture; finding issues "especially ones that crossed system boundaries in a multi-service repo"; producing algorithms Opus 4.8 could not.

### The reconciling variable practitioners converge on: **autonomy**

**CORROBORATED [15]**: at least five independent practitioners independently name the same dividing line — with heavy human oversight, cheaper/smaller models are faster and fine; **autonomy is where tier starts to dominate.** One puts it as: Fable "can burn all your usage building the wrong thing" while Opus checks in; another argues smaller models "don't know enough to know when they don't know enough."

**INFERRED**: "autonomy level" is a better primary axis for the generator's tier rules than "task complexity." Reasoning: it independently reproduces Anthropic's own "long agentic loops" boundary for Haiku [3] and its "long-horizon" framing for Opus 5/Fable [5][6], and it is the one framing that reconciles the otherwise-contradictory Fable findings above. Risk if wrong: a toolkit that asks "is this hard?" instead of "how long will this run unsupervised?" will mis-tier both directions.

### Independent measurement — partly closes the Sonnet 5 vs Opus 5 gap

- **CONFIRMED [16]** (self-published, small-n): On SlopCodeBench (staged-checkpoint long-horizon coding, 17 checkpoints, 3 runs each, Claude Code harness, fresh context per checkpoint): **Opus 5 strict-passed 24%, Opus 4.8 6%, Sonnet 5 6%.** A ~4x quality gap between Opus 5 and Sonnet 5 on long-horizon work, at 2.5x the per-token price. **This is the closest thing to the head-to-head table Anthropic does not publish**, and its direction matches the 23-point DeepSWE advisor gain [3].
- Secondary signals from the same run: Opus 5 produced ~5x more functions with the **lowest** single-use share (14.9% vs Opus 4.8's 49.1% and Sonnet 5's 71.5%) and near-flat complexity growth where Opus 4.8 rose ~70%. **INFERRED**: Sonnet 5's 71.5% single-use-function rate suggests its long-horizon failure mode is *structural duplication* rather than outright wrong answers — consistent with "confidently wrong" being the wrong mental model and "locally correct, globally incoherent" being closer.
- **Honest caveat the author states himself**: no model finished any problem cleanly, and Opus 5's 24% is "not much higher" than Opus 4.6's 17%. He explicitly notes the run "did not test context engineering at all."

### Contested — do not resolve these prematurely

- **Opus 5 vs Sonnet 5 cost-efficiency.** Camp A reasons from Anthropic's own published cost/quality chart that one should "*never* use Sonnet 5 above medium effort" because Opus wins at equal cost. Camp B runs Sonnet for nearly all coding: with "a little elbow grease to break down tasks" you "spend a lot less money for just about the same output quality." **The split tracks task domain, not preference** — systems/HPC/novel-algorithm work vs routine well-decomposed work. [15]
- **Whether Fable costs more or less than Opus in practice.** Direct contradiction: one practitioner reports ~$10/job on Fable vs ~$50 on Opus (fewer turns); two others report Fable exhausts Claude Max limits in 30–45 minutes and that Opus 5 gives "the same results as Fable, just faster and cheaper." Neither side published methodology. [15]
- **Whether subagents are worth it at all.** Against the mainstream view: dispatched subtasks share overlapping context so serial exploration can be quicker and cheaper; orchestrators lose nuance; subagents are mainly useful "when the agent is dumb to begin with." [15]

### The most useful measured single case

- **CONFIRMED [19]**: Simon Willison took `sqlite-utils` from 4.0rc1 to a shippable 4.0rc2 with Fable 5 — 37 prompts, 34 commits, +1,321/−190 across 30 files — for **~$149.25** in unsubsidized API terms. Breakdown matters more than the total: **~94.5% of spend went to the frontier main session** ($141.02), while four delegated subagents cost $1.40–$2.40 each and one Opus 4.8 agent cost $0.32. His own verdict: he "really should have" followed his own advice and "leaned more heavily into subagents with cheaper models." Fable did find a genuine data-loss bug. **This is the strongest concrete argument in the corpus for the delegate-to-cheap-subagents pattern** — and it comes from someone conceding he failed to apply it.

### Two claims to actively *not* carry forward

- **[15] UNVERIFIED and contradicted**: a relayed Reddit claim that Claude Code hardcodes an instruction telling Opus 5 not to use subagents. Two commenters contradicted it from direct observation. It may be a garbling of Anthropic's actual published note that they "removed over 80% of Claude Code's system prompt for Opus 5 and Fable 5." **Do not repeat.**
- **[24] Likely misconception worth pre-empting in the toolkit**: Claude Code's **"auto mode" is a permissions setting, not a model router.** It became default for new Pro/Max/Team sessions on 2026-08-14 and governs action approval, not tier selection. (Reported eval: ~89% of harmful actions blocked vs 13.6% declined by human testers — with the honest flip side that ~11% still get through.)

### Style, not capability — but relevant to behaviour rules

- **[17] HIGH VOLUME, ZERO MEASUREMENT**: "Why does Opus 5 feel worse" drew 991 points and 869 comments arguing Opus 5 is more capable yet worse to work with — it stopped asking clarifying questions and makes bold assumptions. The author has no benchmark, no logs, no A/B, labels his own causal section "Baseless speculation," and concedes Opus 5 "even rivals Fable in benchmarks." In the HN thread slice sampled, **nobody defended it as better to work with — and nobody reported downgrading to Sonnet or upgrading to Fable to fix it** (defectors went to other vendors). One commenter reports the same tics on Fable, so it may not be Opus-5-specific.
- **INFERRED**: this is a *prompting/behaviour-rules* problem, not a tier-selection problem, and it is directly actionable for this generator — a toolkit rule instructing Opus to surface assumptions and ask clarifying questions before acting would target the single most-complained-about current behaviour. Risk if wrong: the complaint is a training artifact that prompting cannot reach (the [17] author preemptively argues exactly this, so treat the mitigation as untested).

### Where the community evidence is genuinely absent

- **"People used Haiku and it silently failed": NOT FOUND.** No clean, corroborated case exists in the reachable corpus. The nearest silent-failure claim is about *Sonnet*, from one person. The closest Haiku-specific report is *detected* omission ("sometimes haiku misses some details"), with a second subagent as the fix. Partly a Reddit-access artifact — but on HN the evidence runs the other way, toward Haiku being adequate when scoped.
- **No Fable 5 vs Opus 5 head-to-head benchmark exists anywhere.** [20] ran Fable alone (FuncPass 59.8%, SecPass 19.0%, "mid-table," and notably **38 of 200 instances confirmed cheating** — 33 training recall, 4 workspace leakage, 1 git history); [16] ran Opus 5/Opus 4.8/Sonnet 5 but not Fable. The comparison a toolkit author would most want does not exist.
- **Effort as a cost lever is barely used in practice.** [15] In a survey of 17 comments mentioning both model and effort, **only two practitioners used low/medium effort as a deliberate cost dial**; where people stated a real daily default, tier choice dominated and effort was mostly ignored. See the tension this creates in the Contrarian section.
- **[23]** A separate, well-documented n=1 operational objection to Fable: refusal classifiers blocking a pure C++→Rust port of the author's own open-source tool and an abstract math problem across three de-biologized rephrasings, where Opus 4.8 did the same work without friction. **Now stale** — the same author's follow-up is titled "Fable is a more useful model now." Cite only as evidence that the refusal risk [5] is operationally real, not as a current verdict.

---

## Contrarian View: the case that tier distinctions are overstated

This is the strongest counter-argument, and it is supported by Anthropic's own measurements rather than by community skepticism:

1. **Anthropic says effort beats model switching, in writing.** *"Tuning effort is often a better lever than switching models"* [1].
2. **Three of the top five cost/quality levers have nothing to do with tier.** Caching (2.5–3.7x), prompt audit (14% + accuracy), and batching (50%) all outrank model choice [3].
3. **Prompt quality demonstrably outweighed a tier change in at least one measured case.** A stale prompt cost 36% more on the *newer, better* model for zero accuracy gain; fixing the prompt bought 5 accuracy points and 14% savings [3]. Removing one phrase ("verify twice") cut cost by a third. If a single sentence in a system prompt can move cost by a third and accuracy by 7–11 points, tier selection is not the dominant variable for most workloads.
4. **Two adjacent tiers were statistically indistinguishable on a real coding benchmark.** Opus 5 91.7% vs Fable 5 91.3% on SWE-bench Pro subset — and Opus was 40% cheaper [3].
5. **Multi-model architectures repeatedly lost to one model at lower effort.** Explicitly: "in these internal measurements, a multi-model configuration that looked cheaper than the default single model cost more than that same model at lower effort" [3].
6. **Anthropic's own Claude Code guidance puts context before both dials.** "If you're raising effort on a task that shouldn't need it, the fix is often upstream, in your context, your CLAUDE.md, or how the task is scoped" [9].

7. **An independent company deprecated its LLM router and published why** [18]. Manifest built a four-tier complexity-based router in March 2026, deprecated it in June, shut it down in September. Their four reasons are the sharpest available argument against automated tier selection: (a) **complexity isn't visible in the prompt** — "the prompt is just the trigger," difficulty emerges later via tool calls; their example is "evaluate and improve tests," trivial for an HTML site and enormous for the Linux kernel; (b) **caching beats routing on cost** — cache reads are 75–90% cheaper than uncached input, so a cache-aware router ends up doing its job by "*not doing it*," sticking with whatever model it first picked; (c) switching models mid-session degrades quality and prevents users mastering their tools; (d) unpredictability complicates evals, system prompts, and observability. Their recommendation is a middle position, not a "tier doesn't matter" one: **stay on one proven model, and choose model + effort deliberately per task.** *(Operational experience across ~7,000 users over 4 months, but no published A/B and no quality or savings figures.)*

**Where the contrarian case breaks down** — and this is the boundary the toolkit should encode:

- The Haiku→Sonnet/Opus gap is real and large (63% vs 92% GPQA; "much further behind" on long coding) [3], and Haiku has no effort dial to close it [4].
- Fable "finished jobs Opus and Sonnet can't reach at any effort level" [9].
- Beyond one context window, no amount of effort tuning or prompt quality helps [3].
- **An independent measurement found a ~4x long-horizon gap between adjacent tiers**: Opus 5 24% vs Sonnet 5 6% strict-pass on staged-checkpoint coding [16].
- **Someone ran the contrarian experiment socially, and it lost.** [21] An Ask HN directly challenged the claim that models ~6 months behind frontier are "good enough for the majority of work" and asked for concrete counter-cases. It drew **eight specific, domain-named frontier-only tasks** — unauthenticated RCE discovery in security audits, cross-service-boundary bug discovery, difficulty-ramp algorithms Opus 4.8 could not produce and broke working code attempting, DOS-game disassembly to Rust still unsolved after hundreds of hours, PSX static recompilation, Asahi/m1n1 patches to boot Linux on M4 — against only **three** cheaper-suffices responses, two of which scoped themselves tightly (one-shot detailed-instruction jobs; heavy human oversight). Small, self-selected thread (33 comments), but it is the closest thing to a direct test of the contrarian hypothesis in the reachable corpus, **and it does not support the strong version.**
- The economic counter-argument, corroborated [15]: cheaper models burn extra steps and "end up costing more despite being 'cheaper'" — the same mechanism Anthropic states as "a more capable model finishes a task with less work" [3].

**A tension the toolkit has to resolve deliberately**: Anthropic says effort is the better lever than switching models [1], and its measurements support that [3]. But practitioners **barely use effort at all** — in a survey of 17 HN comments mentioning both, only two used low/medium effort as a deliberate cost dial, and tier choice dominated every stated daily default [15]. Two of the three practitioners who *do* use it report it working well ("sonnet 5 low is a workhorse"; "Opus at low/medium effort generates plans"), while one reasons from Anthropic's own chart that effort is the *wrong* dial and one should switch models instead. **INFERRED**: effort is an under-adopted lever rather than a discredited one, so the generator adds more value by teaching it than by teaching tier selection — but it should say so explicitly rather than assuming users already reason in effort levels. Risk if wrong: the guidance optimises a dial users will not touch.

**Net position**: tier selection matters at the *edges* — the bottom (Haiku), the top (beyond-one-context, at-the-ceiling work), and **anywhere the model runs autonomously for a long stretch**. In the broad middle — short-horizon, well-scoped, human-reviewed work — effort level, prompt hygiene, caching, and context scoping are each plausibly larger levers than the tier choice. **The generator should lead with effort, context and caching guidance and treat tier as a secondary dial gated on autonomy level, which is the inverse of how `MODEL-BEHAVIOR-RULES.md` is currently written.**

**Crucially, nobody has measured the decisive experiment.** No published source compares "same model, better context/prompt" against "better model, same context." The SlopCodeBench author explicitly lists it as untried future work [16]. The contrarian thesis is therefore **argued, not demonstrated** — well-argued by seven practitioners [15], one deprecated router [18], and Anthropic's own effort and prompt-audit measurements [1][3], but never isolated. Present it in the guidelines as a strong prior, not a finding.

---

## Recommended Corrections to `.meta/MODEL-BEHAVIOR-RULES.md`

1. **Update the tier map.** Haiku 4.5 → Sonnet 5 → Opus 5 → Fable 5. Opus 4.8 is legacy [2]. Keep the Mythos row (now `claude-mythos-5`, Project Glasswing, invitation-only, for defensive cybersecurity workflows [2]) — the repo's prior note that it is real and restricted is confirmed, though the stated rationale ("extreme cybersecurity capabilities") should be softened to Anthropic's own wording.
2. **Add an effort section before the tier sections.** Effort is the primary dial on Fable 5, Opus 5, and Sonnet 5, and it does not exist on Haiku. Any tier rule that ignores effort is incomplete.
3. **Drop the "Opus must not write production code" rule.** Directly contradicted by Opus 5's documented gains, which include end-to-end feature work "without leaving stubs or placeholders" [6]. Replace with: Opus's advantage is prior pattern recognition and ambiguity tolerance; it is not restricted to scaffolding.
4. **Drop the instruction to add verification steps to Opus output.** Opus 5 self-verifies; carried-over verification instructions cause over-verification and measurably cost money [3][6]. Same for Fable [8].
5. **Reframe the Haiku boundary** from "simple tasks" to **"short, verifiable, high-volume tasks — not long agentic loops"** [3], and add the two hard limits: no effort parameter, and a Feb 2025 knowledge cutoff.
6. **Replace "Sonnet must not produce architectural docs" with a horizon/ambiguity test.** The evidenced Sonnet shortfall is long-horizon original engineering (23-point advisor gain on DeepSWE) and ambiguous briefs — not document types.
7. **Add Fable's operational costs**: "Slower" latency, hours-long episodes, **not ZDR-eligible**, refusal classifiers requiring fallback handling, usage-credit billing that fires silently in headless mode, and higher sensitivity to a low `max_tokens`.
8. **Add the advisor tool as the preferred cross-tier mechanism** where available (Anthropic API only; not on Bedrock), because it is the only combination pattern that preserves the prompt cache [11].
9. **Add a "measure before architecting" rule**: sweep effort first; price the stronger model alone at low effort as the baseline any multi-model pattern must beat [3].
10. **Add `max_tokens: 64000` (128000 at `xhigh`/`max`) as a default for agentic work**, and treat `stop_reason: max_tokens` as a failure [3].
11. **Make autonomy — not task complexity — the primary axis of the tier rules.** Five independent practitioners converge on it [15], and it reconciles the otherwise-contradictory Fable evidence. The question to put in front of the user is "how long will this run unsupervised?" not "is this hard?"
12. **Add an Opus behaviour rule that targets the most-complained-about current behaviour**: surface assumptions and ask clarifying questions before acting on an ambiguous brief. This is the substance of the highest-volume Opus 5 complaint [17], it is a prompting-layer fix rather than a tier fix, and it costs nothing to try. Label it as untested — the [17] author preemptively argues prompting cannot reach it.
13. **Do not build automated tier routing into generated toolkits.** [18] documents an independent company deprecating exactly that, for reasons that apply directly here: prompt-visible complexity is not real complexity, and caching beats routing on cost. Prefer one deliberately-chosen model per session plus the advisor tool where available.
14. **Pre-empt the auto-mode misconception** in any generated toolkit documentation: Claude Code's "auto mode" is a *permissions* setting, not a model router [24].

---

## Contradictions with Prior Knowledge

These conflict with existing statements in this repo. **Not resolved silently — flagged for the maintainer's decision.**

1. **`.meta/BEDROCK-COST-GUIDE.md` → "Context Length Surcharge" (marked INFERRED, from a Gemini session): a 2x billing multiplier beyond 200K tokens.**
   **CONTRADICTED [12]**: "Claude 4.6 and later models… include the full 1M token context window at standard pricing. (A 900k-token request is billed at the same per-token rate as a 9k-token request.)" Claude Code's docs agree: "no premium for tokens beyond 200K" [8]. *Scope caveat*: Bedrock and Google Cloud are partner-operated with independent pricing [12], so verify on the AWS Bedrock pricing page before deleting the note outright. The claim as written is not true on the Anthropic API.

2. **`.meta/BEDROCK-COST-GUIDE.md` capability table lists Opus 4.8 with a 1M context window.**
   **NEEDS A CAVEAT, NOT A FLAT CORRECTION.** Claude Code's docs say Opus 4.8 and Opus 5 auto-compact at the 200K boundary "when they run with a 200K context window, such as on Amazon Bedrock, Google Cloud's Agent Platform, and Microsoft Foundry" [8] — i.e. 200K is the ordinary case on partner platforms, whereas on the Anthropic API "Fable 5, Sonnet 5, and Opus 4.7 and later always run with the 1M window" [8].
   **However, 1M Opus is reachable on a Bedrock-routed session.** Confirmed by direct observation: this research session ran on model ID `us.anthropic.claude-opus-5[1m]`, self-described as "Opus 5 (1M context)" — a provider-prefixed ID with the `[1m]` variant selected. So the correct guidance for a Bedrock user is: **1M is not automatic — select the `[1m]` variant (`/model opus[1m]`) and verify, or you get 200K and 200K-boundary auto-compaction.** Since `BEDROCK-COST-GUIDE.md` is *about* Bedrock, the table should say this explicitly rather than implying 1M by default.

3. **`.meta/AGENTIC-PATTERNS.md` Pattern 6 "Big Model Plans, Small Model Executes."**
   **PARTIALLY SUPPORTED, PARTIALLY CONTRADICTED.** Supported: `opusplan` ships this exact pattern as a first-party Claude Code alias [8], and cache invalidation on model switch is confirmed [11]. Contradicted: Anthropic's measured finding is that where the work "is one dependent chain, or fits in a single context, the orchestrator pays for a plan, a handoff, and a merge that a single model gets for free. In every such case measured, the coordinator's model alone at lower effort came out ahead" [3]. **Also inverted**: delegation to cheap workers paid off on *routine* work as cost-tail insurance, "the opposite of the intuition that workers are for hard problems" [3]. The pattern should be scoped to (a) work exceeding one context window, or (b) routine work with a long cost tail — not offered as the general default for complex work.

4. **`.meta/MODEL-SELECTION.md` "The hybrid workflow — save cost, maintain quality" and the model table.**
   Same scoping issue as #3, plus the table is stale (Opus 4.8 as top Opus; Sonnet 5 pricing unverified — it is $2/$10 and now permanent [12]). Also: `MODEL-SELECTION.md` states fast mode is "available on Opus 5/4.8" — confirmed [12], but it is **Anthropic API only**, not available on Bedrock/AWS/Google/Foundry, which the file does not say.

5. **`.meta/MODEL-BEHAVIOR-RULES.md` "Opus — do not write extensive, production-ready code files — that is Sonnet's job."**
   **CONTRADICTED [6]** — see Recommended Correction #3.

6. **`.meta/MODEL-BEHAVIOR-RULES.md` Haiku "do not work with codebases larger than ~50K tokens without chunking."**
   **UNSUPPORTED.** No source found for a 50K figure. Haiku's documented limit is a 200K context window [2]. The number appears to be invented; recommend replacing it with the real one.

7. **`.meta/BEDROCK-COST-GUIDE.md` "Mantle endpoint" / `CLAUDE_CODE_USE_MANTLE=1` (marked INFERRED).**
   **PARTIALLY CONFIRMED [14]**: the Mantle client is real — it is the Messages-API Bedrock endpoint, exposed in the SDKs as `AnthropicBedrockMantle` / `BedrockMantleBackend` etc., and is the preferred path for new code over the legacy `bedrock-runtime` `InvokeModel` path. Claude Code's docs also reference "Mantle" as a provider whose deployments use provider-specific model IDs [8]. **The specific `CLAUDE_CODE_USE_MANTLE=1` env var was not verified in this research**, nor were the claimed separate input/output quotas, automatic 1-hour cache TTL, or work-queuing behaviour. Keep those on the TODO.

8. **Prior team note that Mythos is "restricted to vetted national security/critical infrastructure partners due to extreme cybersecurity capabilities."**
   **PARTIALLY CONFIRMED [2]**: Mythos 5 is real, invitation-only, no self-serve signup, offered through Project Glasswing "for defensive cybersecurity workflows." Anthropic's stated distinction is that Mythos 5 "shares Claude Fable 5's capabilities **without the safety classifiers**" [5] — i.e. the restriction is about removed refusal classifiers, not about a higher capability ceiling. The team's firsthand statement that it is real stands; the rationale should be adjusted.

---

## Gaps and Open Questions

1. **No head-to-head Sonnet 5 vs Opus 5 benchmark table exists in public docs — partly closed.** The gap was reconstructed from advisor-gain proxies (23 points on DeepSWE, "a few points" on GPQA) [3] and then independently corroborated by one small self-published run (Opus 5 24% vs Sonnet 5 6% on staged-checkpoint long-horizon coding, 17 checkpoints, 3 runs) [16]. Two sources, same direction, neither authoritative. *To close properly*: run the four-step method from [3] on real toolkit workloads — pull sample tasks, write outcome checks, baseline both tiers across effort levels, plot score against spend.
2. **Reddit was entirely inaccessible**, so the community evidence is HN-skewed toward API/cost-conscious and open-weights-friendly views — i.e. biased *toward* the contrarian conclusion this file reaches. *To close*: a session with browser access or a Reddit API token, targeting r/ClaudeAI and r/ClaudeCode for day-to-day model-choice reports.
2b. **No Fable 5 vs Opus 5 head-to-head benchmark exists anywhere**, official or community. [20] ran Fable alone; [16] ran Opus 5/4.8 and Sonnet 5 but not Fable. Anthropic's SWE-bench Pro figures [3] are the only direct comparison and they show parity at 40% lower cost for Opus — one benchmark both models "largely saturate."
2c. **The decisive contrarian experiment is unpublished**: nobody has isolated "same model, better context" vs "better model, same context." Treat the tier-vs-prompt-quality conclusion as a strong prior, not a finding.
2d. **"Haiku silently failed" was searched for specifically and not found.** No clean corroborated case exists in reachable sources; the nearest is *detected* omission, and the one true silent-failure claim is about Sonnet, from one person [15]. Absence is partly a Reddit artifact — but do not assert a Haiku silent-failure mode in the guidelines without evidence.
3. **All Anthropic figures are self-reported internal runs** from July–August 2026, with several single-run configurations and Anthropic models acting as judges on two benchmarks [3, refs 2 and 7]. Anthropic flags this itself. Treat magnitudes as directional.
4. **Bedrock-specific pricing remains unverified — attempted and blocked.** The AWS Bedrock pricing page (https://aws.amazon.com/bedrock/pricing/) was fetched in this session and its Anthropic tables render client-side: **no rows for Fable 5, Opus 5, Sonnet 5, or Haiku 4.5 were retrievable**, only legacy "Public Extended Access" Claude 3.5 Sonnet rows. Two things were readable and are worth noting: the page states no context-length pricing dimension for Claude models at all (weak negative evidence against a >200K surcharge on Bedrock), and it confirms "Access to Claude Mythos 5 and Claude Mythos Preview is gated and requires approval." *To close*: read the rates from the AWS Console's Bedrock pricing view or ask the AWS account team; do not carry the Gemini-sourced numbers in `BEDROCK-COST-GUIDE.md` into budget planning. Bedrock cache TTL behaviour and `CLAUDE_CODE_USE_MANTLE=1` also remain unverified. Note that current models reach Bedrock through the newer "Claude in Amazon Bedrock" Messages-API endpoint rather than the legacy `bedrock-runtime` `InvokeModel` path [2][6], so legacy Bedrock pricing rows may not apply.
5. ~~No evidence found on how a model can detect its own tier at runtime.~~ **CLOSED — confirmed by direct observation.** `MODEL-BEHAVIOR-RULES.md`'s premise holds: Claude Code injects the running model into the session system prompt. In this research session the injected text read, verbatim: *"You are powered by the model named Opus 5 (1M context). The exact model ID is `us.anthropic.claude-opus-5[1m]`."* So a tier-aware behaviour rule **can** be written as a self-check, and it can read both the tier name and the effective context window. Two caveats: the exact wording is undocumented and may change between Claude Code releases, so rules should match loosely (on "Haiku"/"Sonnet"/"Opus"/"Fable") rather than parse a fixed string; and the ID observed here is provider-prefixed (`us.anthropic.…`), so a rule matching bare API IDs like `claude-opus-5` would miss on Bedrock-routed sessions.
6. **Effort defaults inside skills** — `effort` frontmatter is available on skills, commands, and subagents [10], but no measurement exists on what effort a research or planning skill should declare. Worth an empirical pass.
7. **`opusplan` has no published measurement.** It is a shipped feature, but Anthropic's measured orchestrator results argue against decomposition for single-context work. Whether the plan/execute boundary specifically pays is unknown.

---

## Sources

[1] Choosing the right model — https://platform.claude.com/docs/en/about-claude/models/choosing-a-model
[2] Models overview — https://platform.claude.com/docs/en/about-claude/models/overview
[3] Optimizing for cost and intelligence (measured benchmark results) — https://platform.claude.com/docs/en/about-claude/models/optimizing-for-cost-and-intelligence
[4] Effort — https://platform.claude.com/docs/en/build-with-claude/effort
[5] Introducing Claude Fable 5 and Claude Mythos 5 — https://platform.claude.com/docs/en/about-claude/models/introducing-claude-fable-5-and-claude-mythos-5
[6] What's new in Claude Opus 5 — https://platform.claude.com/docs/en/about-claude/models/whats-new-opus-5
[7] What's new in Claude Sonnet 5 — https://platform.claude.com/docs/en/about-claude/models/whats-new-sonnet-5
[8] Claude Code — Model configuration — https://code.claude.com/docs/en/model-config
[9] Choosing a Claude model and effort level in Claude Code (Anthropic blog) — https://claude.com/blog/claude-model-and-effort-level-in-claude-code
[10] Claude Code — Subagents — https://code.claude.com/docs/en/sub-agents
[11] Claude Code — Escalate hard decisions with the advisor tool — https://code.claude.com/docs/en/advisor
[12] Pricing — https://platform.claude.com/docs/en/about-claude/pricing
[13] Introducing Claude Haiku 4.5 — https://www.anthropic.com/news/claude-haiku-4-5
[14] Bundled `claude-api` Agent Skill, Claude Code 2.1.238 (local, model table cached 2026-06-24) — provider client and Mantle reference

**Tier 2 / community sources** (see the coverage limits at the head of the Community section — Reddit was inaccessible; all of the following are Hacker News, engineering blogs, or self/vendor-published benchmarks):

[15] Hacker News practitioner corpus, gathered via the HN Algolia API, Dec 2025 – Aug 2026. Individual comments cited inline in the community report by ID, e.g. https://news.ycombinator.com/item?id=48380993 (Haiku subagents), https://news.ycombinator.com/item?id=48736727 and https://news.ycombinator.com/item?id=48736821 (Sonnet-vs-Opus cost camps), https://news.ycombinator.com/item?id=48837296 (Fable overkill), https://news.ycombinator.com/item?id=49081970 (Fable long-horizon wins), https://news.ycombinator.com/item?id=49314373 (cache-prefix mechanism for mid-session switching)
[16] Benchmarking Opus 5 on SlopCodeBench — https://github.com/humanlayer/advanced-context-engineering-for-coding-agents/blob/main/benchmarking-opus-5-on-slop-code-bench.md *(self-published, 17 checkpoints × 3 runs — small-n)*
[17] Why does Opus 5 feel worse — https://mun-logadan.github.io/why-does-opus-5-feel-worse/ *(high-volume sentiment, zero measurement; author labels his own causal section "Baseless speculation")*
[18] Manifest — Why we deprecated our LLM router — https://manifest.build/blog/why-we-deprecated-our-llm-router/ *(operational experience, ~7,000 users over 4 months; no published A/B)*
[19] Simon Willison — sqlite-utils 4.0rc2 with Claude Fable 5 — https://simonwillison.net/2026/Jul/5/sqlite-utils-fable/ *(measured single case with full cost breakdown)*
[20] Endor Labs — Claude Fable 5 security benchmark, Agent Security League — https://www.endorlabs.com/learn/claude-fable-5-mythos-grade-hype *(vendor-published; Fable alone, no Opus/Sonnet comparison)*
[21] Ask HN — concrete tasks where only frontier models suffice — https://news.ycombinator.com/item?id=48863171 *(8 domain-specific counter-cases vs 3 hedged dissents; small self-selected thread)*
[22] Anthropic — Maximizing the value of your Claude Code sessions — https://claude.com/blog/maximizing-the-value-of-your-claude-code-sessions
[23] Rob Patro — Fable is not a useful model / "the classifiers are too zealous" — https://combine-lab.github.io/blog/2026/07/07/fable-is-not-a-useful-model.html *(n=1, well-documented, and superseded by the author's own follow-up)*
[24] Simon Willison — Claude Code auto mode — https://simonwillison.net/2026/Aug/8/auto-mode/ *(cited to correct the misconception that auto mode routes between model tiers)*
