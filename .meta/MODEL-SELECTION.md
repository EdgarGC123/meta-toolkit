# Model Selection Reference

**Purpose**: Quick reference for selecting the right model for a given task.

---

## Key Principle

Model selection is about matching the task to the right capability tier — not defaulting to the most powerful model for everything. Context window size, reasoning depth, and cost all vary and should factor into the decision.

---

## Current Claude Model Reference

**CONFIRMED** — sourced from https://platform.claude.com/docs/en/docs/about-claude/models/overview

| Model | API ID | Context | Best for |
|---|---|---|---|
| **Claude Fable 5** | `claude-fable-5` | 1M tokens | Long-running agents, highest-capability tasks requiring sustained reasoning |
| **Claude Opus 4.8** | `claude-opus-4-8` | 1M tokens | Complex agentic coding, enterprise work, multi-step reasoning |
| **Claude Sonnet 5** | `claude-sonnet-5` | 1M tokens | Best balance of speed and intelligence — default for most tasks |
| **Claude Haiku 4.5** | `claude-haiku-4-5-20251001` | 200k tokens | Fastest with near-frontier intelligence — high-volume, simple tasks |

All current Claude models support text and image input (vision), multilingual capabilities, and are available via Claude API, AWS Bedrock, Google Cloud, and Microsoft Foundry.

---

## Decision Rules

**Default**: Claude Sonnet 5 for most tasks.

**Use Fable 5 when**:
- The task is a long-running agentic workflow requiring sustained, high-quality reasoning across many steps
- Maximum capability is the priority regardless of cost

**Use Opus 4.8 when**:
- The task requires complex multi-step reasoning or agentic coding
- Output quality matters more than latency
- Enterprise or production workload where reliability is critical

**Use Haiku 4.5 when**:
- The task is simple and high-volume (classification, labeling, formatting, extraction)
- Speed and cost efficiency matter more than depth
- Note: Haiku 4.5 has a 200k token context window — not 1M

---

## Tactical Usage Guide

> ### ⚠️ STUB — This section is unvalidated
>
> The guidance below was written from assumptions and from a Google Gemini conversation, **not from verified research**. Specifically unverified: the effort-level cost table, fast mode behavior, and the cache invalidation claims.
>
> Pending research: `research/model-settings-cost.md` and `research/model-tiers-capabilities.md`. Rewrite this section once those land.
>
> The "When to use each tier" table and hybrid workflow pattern are directionally reasonable but should be confirmed. Do not cite the cost numbers below in budget planning until verified.

### When to use each tier

| Situation | Use |
|---|---|
| Writing code, fixing bugs, implementing a story | Sonnet |
| Designing a system, planning an epic, architectural decisions | Opus |
| Simple extraction, formatting, boilerplate generation | Haiku |
| Multi-session autonomous work, very large repo analysis | Fable |
| Everything else | Sonnet (default) |

### The hybrid workflow — save cost, maintain quality

The most cost-efficient pattern for complex work:

1. **Opus session** — define architecture, produce handoff docs (ARCHITECTURE.md, implementation plan, story breakdown with ACs)
2. **Close the Opus session** — cache expires, no ongoing cost
3. **Sonnet session** — reads the static handoff docs, executes the plan cheaply

Switching models mid-session invalidates the cache and forces a re-write at premium cost. Segmenting into clean sessions avoids this.

See `.meta/BEDROCK-COST-GUIDE.md` — "Model Cost Reference" and "Caching Mechanics" for the math behind this.

### Configurations that affect cost

**Effort level** (`--effort` or `effort:` in skill frontmatter)

| Level | Effect | When to use |
|---|---|---|
| `low` | Minimal reasoning, fastest, cheapest | Simple lookups, formatting, boilerplate |
| `medium` | Standard reasoning | Most tasks |
| `high` | Extended thinking enabled, default for Opus/Sonnet in Claude Code | Complex reasoning, architecture, debugging |
| `xhigh` | Deeper extended thinking | Hard problems requiring sustained multi-step reasoning |
| `max` | Maximum thinking budget | Most demanding tasks — use sparingly |

Extended thinking tokens are billed as output tokens. Higher effort = more thinking tokens = higher cost. Opus and Sonnet default to `high` in Claude Code — set explicitly lower for tasks that don't need it.

**Fast mode** (Claude Code)

Fast mode uses Claude Opus with faster output generation. Toggle with `/fast`. Available on Opus 5/4.8. Check current pricing before relying on cost estimates — fast mode billing depends on which model is actually invoked.

**Model switching mid-session**

Each model switch invalidates the prompt cache — you pay a full re-write at the new model's write premium rate. For long sessions, minimize switches. If switching is necessary, do it at a natural break point (end of a phase, after a commit) not mid-task.

**Prompt caching**

The single biggest cost lever. First request with large context pays a write premium; subsequent requests pay ~10% of standard input cost. Cache expires on inactivity (5-minute default, 1-hour extended). See `.meta/BEDROCK-COST-GUIDE.md` for full details.

### Mythos

Real model, not publicly accessible. Restricted to vetted national security and critical infrastructure partners due to extreme cybersecurity capabilities. Fable 5 is the publicly accessible top tier for standard toolkit usage.

---

## Important: Effort Level

Opus 4.8 and Sonnet 5 default to `high` effort in Claude Code and the API. Set `effort` explicitly if you need a different level. Lower effort = faster and cheaper; higher effort = more thorough reasoning. The `effort` parameter is available in skill frontmatter — see `CLAUDE-CODE-SKILLS-REFERENCE.md`.

---

## Where to Get Current Guidance

Model capabilities, context windows, and pricing change frequently. Always verify before making recommendations:
- Official model docs: https://platform.claude.com/docs/en/docs/about-claude/models/overview
- Models API: query programmatically for `max_input_tokens`, `max_tokens`, and capabilities
- Consult your organization's AI tooling guidance for approved models and tiers

Do not cite specific token counts or pricing from memory. Verify against current documentation first.

---

