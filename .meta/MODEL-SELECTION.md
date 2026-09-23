# Model Selection Reference

**Purpose**: Quick reference for selecting the right model for a given task.

---

## Key Principle

Model selection is about matching the task to the right capability tier — not defaulting to the most powerful model for everything. Context window size, reasoning depth, and cost all vary and should factor into the decision.

---

## Current Claude Model Reference

**CONFIRMED** — sourced from official Anthropic model docs. Verify before budget planning — pricing and availability change.

| Model | Tier | Context | Best for |
|---|---|---|---|
| **Claude Fable 5** | Extended autonomous | 1M tokens | Long autonomous runs, very large context, multi-session coordination |
| **Claude Opus 5** | Deep reasoning | 1M (Bedrock: select `[1m]` variant or you get 200K) | Complex analysis, architectural decisions, extended sessions |
| **Claude Sonnet 5** | Execution | 1M tokens | Day-to-day work, story implementation, interactive development. $2/$10 per MTok — now permanent |
| **Claude Haiku 4.5** | Read-and-summarize | 200K tokens | Repetitive single-file tasks, codebase mapping, extraction. No `effort` parameter. Feb 2025 knowledge cutoff. |

**Legacy**: Opus 4.8, Sonnet 4.6 — use current generation for new work.
**Restricted**: Mythos 5 — invitation-only via Project Glasswing (defensive cybersecurity). Not for standard use.

All current models support vision and multilingual. Available via Claude API, AWS Bedrock, Google Cloud, Microsoft Foundry.

---

## Decision Rules

**Default**: Claude Sonnet 5 for most tasks.

Ask: **"How long before I need to course-correct this?"** — that determines tier more reliably than task difficulty.

**Use Haiku 4.5 when**:
- The task is repetitive and well-scoped — same operation applied to many individual items
- Ideal: reading/summarizing files one at a time, extraction, classification, codebase mapping
- Hard limits: no `effort` parameter, 200K context, Feb 2025 knowledge cutoff, no planning mode

**Use Sonnet 5 when**:
- Regular human check-ins, implementing defined stories, interactive development
- Default for most day-to-day work

**Use Opus 5 when**:
- The session will run for a while without supervision, OR the task requires connecting non-obvious dots across a large system
- Complex analysis, architectural decisions, full feature implementation end-to-end
- Note: Opus 5 completes features fully — it does not leave stubs unless that's appropriate

**Use Fable 5 when**:
- Multi-hour autonomous runs, very large context, sessions that need to sustain quality without human checkpoints
- Not for supervised coding — Opus 5 matched Fable on SWE-bench Pro at ~60% of cost for supervised work

---

## Tactical Usage Guide

**Validated** against `research/model-settings-cost.md` and `research/model-tiers-capabilities.md`.

### Lead with these levers — they outrank model selection

Anthropic's measured performance improvements, in descending impact:

| Lever | Measured gain |
|---|---|
| Prompt caching | 2.5–3.7x cost reduction |
| Prompt quality audit | 14% performance + 5 accuracy points |
| Batch processing | 50% cost reduction |
| Effort level tuning | "Often a better lever than switching models" (not quantified per level) |
| Model selection | Real, but lower impact than the above |

**Concrete implication**: a stale prompt cost 36% more on a newer, better model for zero accuracy gain. Fix the prompt before upgrading the model.

### Effort levels — the most under-used lever

**CONFIRMED** — affects all token spend (text, tool calls, and thinking)

| Level | Effect | When to use |
|---|---|---|
| `low` | Minimal reasoning, fewest tool calls, cheapest | Simple lookups, formatting, extraction |
| `medium` | Standard reasoning | Most tasks |
| `high` | Default for Opus and Sonnet in Claude Code | Complex reasoning, debugging, architecture |
| `xhigh` | Deeper extended thinking | Hard multi-step problems |
| `max` | Maximum thinking budget | Most demanding — use sparingly |

Effort affects *all* token spend, including how many tool calls the model makes. At `low` effort Claude combines operations; at `high` it's more thorough. Default is `high` for Opus and Sonnet in Claude Code. Set it lower explicitly when you don't need it.

Effort is available in skill frontmatter: `effort: medium`. See `CLAUDE-CODE-SKILLS-REFERENCE.md`.

**Bedrock note**: `fast` mode is **Anthropic API only** — not available on Bedrock, Google Cloud, Foundry, or Claude Platform on AWS.

### Prompt caching

The single biggest lever. First request with large context: cache write (premium cost). Subsequent requests reusing the same prefix: cache read (~10% of standard input cost).

- **5-minute TTL** (default): resets on every cache hit. Break-even: **one** cache read.
- **1-hour TTL** (opt-in): `ENABLE_PROMPT_CACHING_1H=1` in Claude Code. Costs 2x write premium (vs 1.25x for 5-min). Break-even: **two** reads.
- Cache is model-specific. A new session on the same model still hits cache for the same content.

See `.meta/BEDROCK-COST-GUIDE.md` for full caching mechanics.

### Segmenting work across models

When work genuinely exceeds one context window, or when you need to hand off routine execution to a cheaper model:

1. Use Opus/Sonnet to produce a **durable artifact** — a plan, an APP-CONTEXT.md, an architecture doc. Write it to a file, not just a conversation.
2. Start a new session on the cheaper model. It reads the artifact and caches it.

**Why this works**: the artifact survives session death, token expiry, switching machines, and days passing. The conversation does not. The cost benefit is real but secondary to the durability benefit.

**INFERRED — not yet empirically verified**: switching models invalidates the prompt cache. If true, you avoid re-caching the full prior conversation by segmenting — but you still pay a cache write on the artifact in the new session. The net saving depends on how large the prior context was. See `research/model-settings-cost.md`.

**When segmenting does NOT help**: if the work fits in one context and you'd otherwise pay for plan + handoff + execution, a single Opus session at lower effort usually comes out ahead.

### Context window on Bedrock — Opus note

On Bedrock, Opus models default to a 200K window and auto-compact at that boundary unless you explicitly select the `[1m]` variant. Use `/model opus[1m]` or equivalent to get the 1M window.

---

## Important: Effort Level

Opus 5 and Sonnet 5 default to `high` effort in Claude Code and the API. Haiku 4.5 has **no effort parameter**. Set `effort` explicitly when the task doesn't warrant the default. Lower effort = fewer thinking tokens and fewer tool calls = faster and cheaper. The `effort` parameter is available in skill frontmatter — see `CLAUDE-CODE-SKILLS-REFERENCE.md`.

---

## Where to Get Current Guidance

Model capabilities, context windows, and pricing change frequently. Always verify before making recommendations:
- Official model docs: https://platform.claude.com/docs/en/docs/about-claude/models/overview
- Models API: query programmatically for `max_input_tokens`, `max_tokens`, and capabilities
- Consult your organization's AI tooling guidance for approved models and tiers

Do not cite specific token counts or pricing from memory. Verify against current documentation first.

---

