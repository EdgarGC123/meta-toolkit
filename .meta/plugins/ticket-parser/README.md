# Plugin: Ticket Parser

**Pattern**: Prompts-only
**Invocation type**: On-demand (generates a `/ticket-parser` command)  
**Use case**: Takes raw ticket text from any project management tool (Jira, Linear, GitHub Issues) and extracts tasks, acceptance criteria, checklist items, and out-of-scope notes into a structured format.

---

## What It Does

Parses unstructured ticket text into a clean, structured output. Handles all common AC formats in the wild:
- Given/When/Then (enterprise/QA-heavy teams)
- Checklist style (GitHub/Linear default)
- "Done when:" prose lists (Jira default)
- Mixed/unstructured (most common — the default case)

Flags ambiguous or unverifiable ACs rather than silently normalizing them. Handles the "no ACs found" case explicitly.

## When to Use

- At story intake, before codebase exploration begins
- When ticket quality is inconsistent and you need a reliable extraction step
- Works with any ticket source — paste the raw text

## Output Format

```
## Tasks
- [ ] [task 1]
- [ ] [task 2]

## Acceptance Criteria
- [ ] [AC 1]
- [ ] [AC 2]

## Out of Scope
- [item]

## Dependencies
- [item]

## Flags
- ⚠️ [ambiguous or unverifiable item — needs clarification]
```

## Configuration (CONFIG.md)

Optional: set `TEAM_AC_FORMAT` to match your team's AC style (given-when-then / checklist / done-when / auto-detect). Default is auto-detect.

## Part of the Agile Dev Loop Bundle

Works best alongside `standup-summary` and `code-review-checklist` — together they cover story intake, daily standup, and PR review.
