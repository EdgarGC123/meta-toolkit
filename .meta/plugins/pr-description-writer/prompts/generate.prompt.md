# PR Description Writer Prompt

## Variables
- `{{CHANGE_SUMMARY}}` — required: what changed and why (rough notes OK)
- `{{TICKET_REF}}` — optional: ticket/issue reference (e.g. PROJ-123)
- `{{CHANGE_TYPE}}` — optional: feature | bugfix | refactor | chore | dependency-update
- `{{TEST_NOTES}}` — optional: how to verify the change works

---

Generate a PR description for the change below.

Ticket: {{TICKET_REF}}
Change type: {{CHANGE_TYPE}}

What changed:
```
{{CHANGE_SUMMARY}}
```

How to test: {{TEST_NOTES}}

## Output Format

```markdown
## Summary
[2-3 sentences: what this PR does and why. Lead with the outcome, not the implementation.]

## Changes
- [specific change 1]
- [specific change 2]

## How to Test
[Steps to verify the change works. If TEST_NOTES were provided, expand them into numbered steps. If not, write what a reviewer would naturally do to verify this.]

## Notes for Reviewer
[Anything the reviewer should know: areas of risk, design decisions made, follow-up work deferred, known limitations. Omit this section if nothing notable.]

Closes: {{TICKET_REF}}
```

## Rules

- Summary leads with outcome: "Adds X so that Y" not "This PR modifies file Z"
- Changes list is specific — "Adds retry logic to the payment API client" not "Updated services"
- If TICKET_REF is provided, include "Closes: #N" or the appropriate closing keyword
- Omit "Notes for Reviewer" if there's nothing notable — an empty section is worse than no section
