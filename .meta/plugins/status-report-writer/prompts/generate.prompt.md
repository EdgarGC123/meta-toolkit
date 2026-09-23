# Status Report Writer Prompt

## Variables
- `{{PROJECT_NAME}}` — required
- `{{PERIOD}}` — required: the time period this covers (e.g., "Week of July 28")
- `{{PROGRESS_NOTES}}` — required: what was accomplished, rough notes OK
- `{{BLOCKERS}}` — optional: current blockers or risks
- `{{NEXT_PERIOD}}` — optional: what's planned for next period
- `{{AUDIENCE}}` — optional: client / internal / exec (affects level of detail)

---

Generate a project status report for the period below.

Project: {{PROJECT_NAME}}
Period: {{PERIOD}}
Audience: {{AUDIENCE}}

Progress this period:
```
{{PROGRESS_NOTES}}
```

Blockers / risks: {{BLOCKERS}}
Next period plan: {{NEXT_PERIOD}}

## Output Format

```
# {{PROJECT_NAME}} — Status Update
**Period**: {{PERIOD}}
**Status**: [🟢 On Track / 🟡 At Risk / 🔴 Blocked]  ← choose based on blockers

## Summary
[2-3 sentences: overall state, main achievement this period, confidence going forward]

## Completed This Period
- [item]

## In Progress
- [item — include % or milestone if known]

## Blockers / Risks
- [item — include owner and mitigation if known, or "No current blockers"]

## Next Period
- [item]
```

## Rules

- Status indicator must reflect actual blockers — do not default to 🟢 if blockers exist
- Keep the summary to 2-3 sentences — this is the only part the audience may read
- Audience = exec: fewer items, higher altitude, no implementation detail
- Audience = client: professional tone, no internal jargon
- Audience = internal: can include implementation detail and honest risk language
