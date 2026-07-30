# Plugin: Code Review Checklist

**Pattern**: Prompts-only
**Invocation type**: On-demand (generates a `/code-review-checklist` command)  
**Use case**: Given a description of changed files or a diff, produces a structured checklist of things to verify before opening a PR. Specific to the described change — not a generic checklist.

---

## What It Does

Generates a targeted PR review checklist based on the actual change being made. Skips irrelevant categories (no DB migration items on a CSS-only change). Caps at 15–20 items — reviewers stop reading above that.

Covers the categories most commonly missed in real-world code reviews:
- Error handling and edge cases
- Security
- Test coverage quality (not just existence)
- Breaking changes and backward compatibility
- Side effects on other parts of the system

## When to Use

- Before opening a PR — self-review pass
- When pairing: gives the other developer a starting point
- For complex changes where you want to be systematic before asking for review

## Output Format

Categorized checklist, capped at 15–20 items:

```
## Correctness
- [ ] [check]

## Error Handling
- [ ] [check]

## Tests
- [ ] [check]

## Breaking Changes
- [ ] [check]

## Security
- [ ] [check]

## Observability
- [ ] [check]

## Documentation
- [ ] [check]
```

## Configuration (CONFIG.md)

Optional: set `TEAM_FOCUS` to add weight to specific categories your team cares about most.

## Part of the Agile Dev Loop Bundle

Works best alongside `ticket-parser` and `standup-summary` — together they cover story intake, daily standup, and PR review.
