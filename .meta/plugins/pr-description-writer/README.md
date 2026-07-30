# Plugin: PR Description Writer

**Pattern**: Prompts-only
**Invocation type**: On-demand
**Status**: Starter — the sections and labels match GitHub PR conventions; adjust for your team's PR template if one exists

---

## What It Does

Generates a structured PR description from a summary of what changed and why. Covers the sections reviewers actually need: what changed, why, how to test, and any notes for the reviewer.

## When to Use

- Before opening a PR — fills in the description rather than leaving it blank
- Pairs well with `code-review-checklist`: write the description first, then generate the checklist

## Part of the Agile Dev Loop Bundle

Works alongside `ticket-parser` (story intake), `standup-summary` (daily standup), and `code-review-checklist` (pre-PR self-review).
