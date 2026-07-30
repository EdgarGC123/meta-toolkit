# Plugin: Stand-up Summary

**Pattern**: Prompts-only
**Invocation type**: On-demand (generates a `/standup-summary` command)  
**Use case**: Converts implementation notes or a story summary into a spoken-word stand-up update — 3–4 sentences you say out loud, not a written document.

---

## What It Does

Produces a plain-text, spoken-register stand-up update from rough implementation notes. Designed for the daily standup: what you did, where you are, what's next, and whether you're blocked.

Key design decision: **no bullet points, no markdown, no headers** — the output must be speakable as-is without interpretation.

## When to Use

- End of a coding session, before standup
- When you have notes or a summary but need to translate them into a clean verbal update
- Works for both synchronous standups and async text standups (with the format toggle)

## Output Format

Plain text, 3–4 sentences, conversational register. Example:

> Yesterday I finished the authentication middleware and got the token refresh flow working. I'm now starting on the user profile API — the endpoint is scaffolded and I'm wiring up the database calls. No blockers right now, should have something reviewable by end of day.

## Configuration (CONFIG.md)

Optional: set `FORMAT` to `spoken` (default) or `async-text`. Async-text mode produces a slightly more structured update suitable for Slack/Teams.

## Part of the Agile Dev Loop Bundle

Works best alongside `ticket-parser` and `code-review-checklist` — together they cover story intake, daily standup, and PR review.
