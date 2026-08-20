# Bedrock Cost and Setup Guide

**Purpose**: Practical reference for running Claude Code via Amazon Bedrock in a personal AWS account. Covers setup, caching mechanics, cost patterns, and the hybrid model workflow strategy.

**Confidence notes**: Items marked **CONFIRMED** are sourced from official docs or our own research. Items marked **INFERRED** are drawn from the Gemini conversation (2026-08-06) and should be verified against official AWS/Anthropic docs before relying on them in production. See TODO.md for verification items.

---

## Basic Setup (Personal AWS Account)

**CONFIRMED** — sourced from code.claude.com/docs/en/amazon-bedrock

Minimum environment variables to route Claude Code through Bedrock:

```bash
export CLAUDE_CODE_USE_BEDROCK=1
export AWS_REGION=us-east-1         # or your preferred region
```

**IAM Policy (minimum required)**:
Create a dedicated IAM User or Role for Claude Code with only `bedrock:InvokeModel` permissions. Never run Claude Code with root account or `AdministratorAccess`. Claude Code executes shell commands on your machine and has access to your local environment variables — scoping its IAM permissions is a real security control.

**No idle cost**: As long as you are not making API calls, Bedrock costs exactly $0. There are no standing infrastructure charges for direct API usage (unlike Knowledge Bases, which provision an OpenSearch instance even at zero traffic).

---

## Caching Mechanics

**CONFIRMED** — sourced from research/hooks.md, research/caching-context.md, and official Bedrock docs

Prompt caching is the single biggest lever for cost optimization on repeated/long-context work.

### How it works

- First request with a large context (codebase, system prompt, reference docs): **cache write** — billed at a premium
- Subsequent requests reusing the same prefix: **cache read** — ~90% cheaper than standard input
- Cache is ephemeral — it lives on AWS GPU memory, not on your machine

### TTL (Time To Live)

The cache has a sliding TTL that resets on every cache hit:

| TTL option | Write cost multiplier | Read cost | Notes |
|---|---|---|---|
| 5-minute (default) | ~1.25x standard input | ~0.10x standard input | Resets on every hit; survives active coding sessions |
| 1-hour (extended) | ~2x standard input | ~0.10x standard input | Survives lunch breaks; higher write cost |

Cache break-even: approximately 2 reads. After 2 reads, caching saves money.

### What invalidates the cache (forces a re-write)

**CONFIRMED** — sourced from official docs and Gemini conversation cross-checked against Claude Code docs:

1. **Switching models** — cache is model-specific. Switching from Opus to Sonnet mid-session means Sonnet must re-read the full context, billed at the write premium
2. **Changing effort level** — the cache is keyed by reasoning depth; switching `--effort` mid-session breaks the prefix
3. **Enabling fast mode** — appends a different header to the API call, creating a new cache key
4. **Modifying the system prompt** — everything after the changed line is invalidated
5. **Token expiry + Ctrl+C** — the cache TTL continues running while you're re-authenticating; if the gap exceeds the TTL, you pay a re-write on the next request

### Practical implication: segment by model

Because model switching invalidates cache, the most cost-efficient workflow is:

1. Use a large model (Opus/Fable) for planning and architecture — work until you have a complete, stable output
2. Write the output to static markdown files (e.g., `ARCHITECTURE.md`, `implementation-plan.md`)
3. Close the session
4. Open a fresh session with a smaller model (Sonnet/Haiku)
5. The smaller model reads the static markdown files once, caches them, and uses them cheaply for the rest of the execution work

This avoids paying the cache re-write penalty that model switching triggers mid-session.

---

## Model Cost Reference

**INFERRED from Gemini conversation — verify against official docs before use in budget planning**

Approximate pricing on Amazon Bedrock (standard on-demand, US regions):

| Model | Input (per 1M) | Output (per 1M) | Cache Write | Cache Read |
|---|---|---|---|---|
| Claude Haiku 4.5 | $1.00 | $5.00 | $1.25 | $0.10 |
| Claude Sonnet 4.6 | $3.00 | $15.00 | $3.75 | $0.30 |
| Claude Sonnet 5 | verify | verify | verify | verify |
| Claude Opus 4.8 | verify | verify | verify | verify |
| Claude Fable 5 | verify | verify | verify | verify |

Cross-region inference profiles add ~10% premium. Priority tier adds ~75% premium.

**Always verify current pricing**: https://platform.claude.com/docs/en/docs/about-claude/models/overview and the AWS Bedrock pricing page.

---

## Model Capability Tiers for Workflow Design

**CONFIRMED** — aligns with MODEL-SELECTION.md

| Tier | Models | Context | Best for |
|---|---|---|---|
| Planning / Architecture | Fable 5, Opus 4.8 | 1M | Multi-step reasoning, system design, complex debugging, large repo exploration |
| Execution / Daily Driver | Sonnet 5, Sonnet 4.6 | 1M | Code writing, file edits, multi-turn workflows, most day-to-day tasks |
| High-volume / Simple | Haiku 4.5 | 200K | Classification, formatting, extraction, test generation, simple Q&A |

**Haiku limitation**: 200K context means it cannot ingest a large codebase in one pass. Use Sonnet or above for full-repo work.

---

## The Mantle Endpoint

**INFERRED — needs verification**

Gemini describes an "Amazon Bedrock Mantle endpoint" that:
- Separates input and output token quotas (prevents heavy input from blocking generation)
- Extends cache TTL to 1 hour automatically
- Uses work-queuing instead of hard 429 errors during heavy usage

Claimed env var: `CLAUDE_CODE_USE_MANTLE=1`

**Status**: Not confirmed against official AWS/Anthropic docs. Add to TODO.md for verification before relying on this.

---

## Security Notes

**CONFIRMED** — sourced from official AWS and Anthropic docs

- AWS Bedrock does not train AI models on your prompts or source code
- Data processed through Bedrock API falls under AWS enterprise-grade terms
- Once a request is processed, the code is no longer in active GPU memory
- AWS internal system logs may temporarily retain API inputs/outputs — avoid hardcoding secrets in files Claude will read

**Sensitive file protection**: Claude Code supports a `.claudeignore` file (similar to `.gitignore`) to prevent it from reading specified files. Use this for files containing API keys, credentials, or proprietary data you don't want sent to the API.

---

## Context Length Surcharge

**INFERRED — needs verification**

Gemini describes a 2x billing multiplier for tokens beyond 200K in a single prompt on models with 1M context windows. If accurate, this makes prompt caching even more critical for large-context work.

---

## See Also

- `.meta/MODEL-SELECTION.md` — model table and decision rules
- `.meta/AGENTIC-PATTERNS.md` — "Big Model Plans, Small Model Executes" pattern
- `TODO.md` — verification items for unconfirmed Bedrock details
