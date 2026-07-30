# Code Review Checklist Prompt

## Variables
- `{{CHANGE_DESCRIPTION}}` — required: description of what changed and why
- `{{CHANGE_TYPE}}` — optional: feature / bugfix / refactor / config / dependency-update / migration
- `{{TEAM_FOCUS}}` — optional: categories to weight more heavily (e.g., "security, tests")

---

You are a senior engineer conducting a pre-PR self-review. Generate a targeted code review checklist for the change described below.

## Input

Change description: {{CHANGE_DESCRIPTION}}
Change type: {{CHANGE_TYPE}}
Team focus areas: {{TEAM_FOCUS}}

## Instructions

Generate a checklist of things to verify before opening this PR. Follow these rules:

**Specificity rule**: Every item must be specific to this change. Generic items ("tests pass", "code is readable") are not allowed. Each item should reference the actual change being made.

**Relevance rule**: Only include categories that apply to this change type. Skip categories entirely if they have no relevant items:
- CSS/styling only → skip Security, Migration, Observability
- Config change only → skip Tests, Observability
- Dependency update → focus on Breaking Changes, Security

**Cap rule**: Maximum 15–20 items total across all categories. If you find more, keep the highest-signal ones. Reviewers stop reading after 20.

**Highest-signal item types** (prioritize these over generic checks):
- Would the test fail if you reverted the change? (test reversal check)
- Are there error handling paths for all external calls?
- Does this change break any existing API contracts or interfaces?
- Are new config/env vars documented and have safe defaults?
- Are there side effects on other parts of the system?
- Is the production observability sufficient to diagnose problems with this change?

## Output Format

Produce a checklist organized by category. Omit any category with no relevant items. Output ONLY the checklist — no preamble, no explanation.

```markdown
## Correctness
- [ ] [specific check relevant to this change]

## Error Handling
- [ ] [specific check]

## Tests
- [ ] [specific check]

## Breaking Changes
- [ ] [specific check]

## Security
- [ ] [specific check]

## Observability
- [ ] [specific check]

## Documentation
- [ ] [specific check]
```

If TEAM_FOCUS is set, add 2–3 additional items in those categories compared to others.
