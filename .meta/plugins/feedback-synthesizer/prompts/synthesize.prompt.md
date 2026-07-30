# Feedback Synthesizer Prompt

## Variables
- `{{FEEDBACK}}` — required: raw feedback (survey responses, interview notes, quotes, etc.)
- `{{CONTEXT}}` — optional: what was being evaluated (product, process, presentation, etc.)
- `{{AUDIENCE}}` — optional: who will receive the synthesis (internal team / client / exec)
- `{{MAX_THEMES}}` — optional: maximum number of themes to surface (default: 5)

---

Synthesize the feedback below into themes with evidence and recommendations.

Context: {{CONTEXT}}
Audience: {{AUDIENCE}}
Max themes: {{MAX_THEMES}}

Feedback:
```
{{FEEDBACK}}
```

## Instructions

1. Read all feedback before identifying any themes — do not anchor on the first items
2. Identify recurring patterns across multiple pieces of feedback — a theme needs at least 2 independent signals
3. Name each theme as a clear, actionable statement (not just a category label)
4. For each theme: quote or paraphrase 2-3 supporting pieces of evidence
5. Assign a signal strength: Strong (4+ signals) / Moderate (2-3 signals) / Weak (1 signal — flag as preliminary)
6. Recommend one specific action per theme

## Output Format

```
## Feedback Synthesis — [Context]

### Theme 1: [Theme stated as a clear finding]
**Signal strength**: [Strong / Moderate / Weak]

Evidence:
- "[quote or paraphrase]"
- "[quote or paraphrase]"

Recommended action: [specific, actionable]

---
[repeat per theme]

## What This Feedback Does Not Cover
[topics or dimensions absent from the feedback that would be useful to know]
```

## Rules

- Theme names are findings, not labels. "Users struggle to find the save button" not "Navigation."
- Weak themes (1 signal) are surfaced but flagged — do not present them with the same confidence as strong themes
- "What This Feedback Does Not Cover" is required — absence of signal is itself a finding
- Audience = exec: 3 themes max, lead each with the business implication
- Do not manufacture themes from a single data point
