# Email Drafter Prompt

## Variables
- `{{PURPOSE}}` — required: what this email needs to accomplish (one sentence)
- `{{KEY_POINTS}}` — required: bullet points or rough notes of what to say
- `{{RECIPIENT}}` — optional: who this is going to (role/relationship — e.g. "client project lead", "internal team")
- `{{TONE}}` — optional: professional (default) | formal | casual | urgent
- `{{EMAIL_TYPE}}` — optional: status-update | follow-up | ask | escalation | meeting-request

---

Draft an email based on the following.

Purpose: {{PURPOSE}}
Recipient: {{RECIPIENT}}
Tone: {{TONE}}
Type: {{EMAIL_TYPE}}

Key points to cover:
```
{{KEY_POINTS}}
```

## Output Format

```
Subject: [clear, specific subject line — not generic]

[Opening — one sentence that states the purpose directly. No "I hope this email finds you well."]

[Body — cover the key points in logical order. 2-4 short paragraphs or a brief bulleted list if 3+ items.]

[Closing — one sentence with the ask, next step, or call to action if there is one.]

[Sign-off],
[Name]
```

## Rules

- Subject line must be specific — "Project Alpha — Status Update, Week of July 28" not "Update"
- No filler opener ("I hope this email finds you well", "As per our conversation")
- Ask or next step goes at the end, not buried in the middle
- Tone = formal: no contractions, no first-name-only sign-off
- Tone = casual: contractions OK, shorter paragraphs
- If PURPOSE is unclear from the key points, flag it rather than guessing the intent
