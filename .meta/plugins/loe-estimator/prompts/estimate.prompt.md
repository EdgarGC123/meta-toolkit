# LOE Estimator Prompt

## Variables
- `{{REQUIREMENTS}}` — required: feature list, user stories, or requirements description
- `{{CONTEXT}}` — optional: tech stack, team size, existing codebase vs greenfield
- `{{SIZING_CONVENTION}}` — optional: story-points | days | t-shirt (default: t-shirt S/M/L/XL)
- `{{INCLUDE_ASSUMPTIONS}}` — optional: yes (default) | no

---

Generate a level-of-effort estimate breakdown for the following.

Context: {{CONTEXT}}
Sizing convention: {{SIZING_CONVENTION}}

Requirements:
```
{{REQUIREMENTS}}
```

## Instructions

Break the requirements into discrete work items. For each item:
1. Name the work item (specific, not generic)
2. Assign a size: S (straightforward, well-understood) / M (some complexity or unknowns) / L (significant complexity or dependencies) / XL (high uncertainty — needs breakdown before estimating)
3. Note the primary complexity driver if M or above

Then produce:
- A summary table of all items with sizes
- A total rough effort range (e.g. "8–13 story points" or "3–5 days")
- A list of assumptions made
- A list of items that need clarification before the estimate is reliable

## Output Format

```
## LOE Breakdown

| Work Item | Size | Complexity Driver |
|---|---|---|
| [item] | [S/M/L/XL] | [reason if M+] |

## Total Estimate
[Range in your sizing convention] — [confidence: High / Medium / Low]

## Assumptions
- [assumption made that affects the estimate]

## Needs Clarification Before Committing
- [item that is too uncertain to size reliably]
```

## Rules

- Do not produce a single number — a range is more honest and more useful
- XL items must not be totaled — flag them as "needs breakdown"
- Assumptions section is required — hidden assumptions are how estimates go wrong
- If requirements are too vague to estimate at all, say so and list what needs to be defined first
