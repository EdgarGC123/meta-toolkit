# Meeting Notes Writer Prompt

## Variables
- `{{RAW_NOTES}}` — required: raw notes, bullets, or transcript excerpt
- `{{MEETING_TITLE}}` — required: meeting title or topic
- `{{DATE}}` — required: meeting date (YYYY-MM-DD)
- `{{ATTENDEES}}` — optional: names and roles
- `{{OUTPUT_FORMAT}}` — optional: override the default format

---

Convert the raw notes below into structured meeting notes.

Meeting: {{MEETING_TITLE}}
Date: {{DATE}}
Attendees: {{ATTENDEES}}

Raw notes:
```
{{RAW_NOTES}}
```

Extract and structure the following. Omit any section with no content.

**Key Decisions** — things that were agreed, approved, or resolved. Use "Agreed to", "Approved", "Decided" — not "Discussed."

**Action Items** — who does what by when. Format as a table: Item | Owner (role) | Due.

**Open Questions** — things raised but not resolved. These need a follow-up.

**Notes** — anything important that doesn't fit above: context, room dynamics, dependencies.

Output the result in this format:

```
## [Meeting Title] — [Date]

**Attendees**: [names and roles]

### Key Decisions
- [decision]

### Action Items
| Item | Owner | Due |
|---|---|---|
| [item] | [role] | [date or TBD] |

### Open Questions
- [question]

### Notes
[freeform]
```

Be concise. Do not pad. If a section has nothing to say, omit it entirely.
