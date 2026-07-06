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

## Important: Effort Level

Opus 4.8 and Sonnet 5 default to `high` effort in Claude Code and the API. Set `effort` explicitly if you need a different level. Lower effort = faster and cheaper; higher effort = more thorough reasoning. The `effort` parameter is available in skill frontmatter — see `CLAUDE_CODE_SKILLS_REFERENCE.md`.

---

## Where to Get Current Guidance

Model capabilities, context windows, and pricing change frequently. Always verify before making recommendations:
- Official model docs: https://platform.claude.com/docs/en/docs/about-claude/models/overview
- Models API: query programmatically for `max_input_tokens`, `max_tokens`, and capabilities
- Consult your organization's AI tooling guidance for approved models and tiers

Do not cite specific token counts or pricing from memory. Verify against current documentation first.

---

**Version**: 2.0
**Last Updated**: 2026-07-05
