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

**IAM Policy (minimum required)**

**CORRECTION (2026-08-06)**: A previous version of this guide said `bedrock:InvokeModel` alone was sufficient. **It is not — Claude Code will fail to run.** Six actions across two statements are required.

**CONFIRMED** — sourced from https://code.claude.com/docs/en/amazon-bedrock

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowModelAndInferenceProfileAccess",
      "Effect": "Allow",
      "Action": [
        "bedrock:InvokeModel",
        "bedrock:InvokeModelWithResponseStream",
        "bedrock:ListInferenceProfiles",
        "bedrock:GetInferenceProfile"
      ],
      "Resource": [
        "arn:aws:bedrock:*:*:inference-profile/*",
        "arn:aws:bedrock:*:*:application-inference-profile/*",
        "arn:aws:bedrock:*:*:foundation-model/*"
      ]
    },
    {
      "Sid": "AllowMarketplaceSubscription",
      "Effect": "Allow",
      "Action": [
        "aws-marketplace:ViewSubscriptions",
        "aws-marketplace:Subscribe"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:CalledViaLast": "bedrock.amazonaws.com"
        }
      }
    }
  ]
}
```

Create a dedicated IAM User or Role for Claude Code with this policy. Never run Claude Code with a root account or `AdministratorAccess` — Claude Code executes shell commands on your machine and has access to your local environment variables, so scoping its IAM permissions is a real security control.

**Interactive setup path (easier)**: Select **3rd-party platform → Amazon Bedrock** at login, or run `/setup-bedrock`. It detects credentials, resolves the region, verifies invokable models, pins them, and writes to the `env` block of `~/.claude/settings.json`.

**`AWS_REGION` is optional** as of v2.1.172. Resolution order: `AWS_REGION` → `AWS_DEFAULT_REGION` → active AWS profile's `region` → `us-east-1`. Set it only to override.

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

- Data handling for Bedrock is governed by Amazon Bedrock terms
- Anthropic states Bedrock runs "with zero operator access (Anthropic personnel have no access to the inference infrastructure)"
- Avoid hardcoding secrets in files Claude will read

**UNVERIFIABLE — removed**: earlier versions of this guide claimed "once a request is processed, the code is no longer in active GPU memory." No Anthropic or AWS doc describes the cache storage substrate. Do not make claims about GPU memory. Use the sourced statements above instead.

### Sensitive file protection — `.claudeignore` DOES NOT EXIST

**CORRECTION (2026-08-06)**: A previous version of this guide instructed users to create a `.claudeignore` file to prevent Claude from reading sensitive files. **That file has no effect.** Zero matches in the Claude Code settings reference. Anyone who followed that guidance believed secrets were protected while nothing was blocking access.

**The real mechanism** is `permissions.deny` with `Read()` glob rules in `.claude/settings.json`:

```json
{
  "permissions": {
    "deny": [
      "Read(./.env)",
      "Read(./.env.*)",
      "Read(./secrets/**)",
      "Read(./**/credentials.json)"
    ]
  }
}
```

For enforcement that cannot be overridden by project or user settings, place the deny rules in `managed-settings.json` with `allowManagedPermissionRulesOnly`.

Note: deny rules are evaluated before allow rules, so a `Read(/**)` allow does not override a specific `Read(./.env)` deny.

---

## Context Length Pricing — Flat, No Surcharge

**CONFIRMED** — https://platform.claude.com/docs/en/about-claude/pricing

There is **no** pricing multiplier for large contexts. Verbatim from the pricing page:

> "Claude 4.6 and later models and Claude Mythos Preview include the full 1M token context window at standard pricing. (A 900k-token request is billed at the same per-token rate as a 9k-token request.) Prompt caching and batch processing discounts apply at standard rates across the full context window."

**CORRECTION (2026-08-06)**: An earlier version of this guide carried a claim of a ~2x billing multiplier for tokens beyond 200K. That claim was **fabricated** — refuted independently by two research passes against the official pricing page. It likely originated as a garbled memory of the retired Sonnet 4.x 1M-context beta premium. Anyone using it for estimates would have inflated large-context costs by up to 2x.

### The real large-context cost lever: tokenizer generation

**CONFIRMED**: Models from 4.7 onward use a tokenizer that produces roughly **30% more tokens for the same text**. This affects Opus 4.7 / 4.8 / 5, Fable 5, and Sonnet 5. Sonnet 4.6 and earlier do not have it.

Practical consequence: Sonnet 5 at $2/MTok input vs Sonnet 4.6 at $3/MTok is **not** a 33% saving. The token count for identical input is higher on Sonnet 5, which erodes much of the per-token advantage. Any naive cross-generation cost comparison is invalid — compare cost per *task*, not cost per token.

---

## See Also

- `.meta/MODEL-SELECTION.md` — model table and decision rules
- `.meta/AGENTIC-PATTERNS.md` — "Big Model Plans, Small Model Executes" pattern
- `TODO.md` — verification items for unconfirmed Bedrock details
