# Meeting Notes Template

**When to use**: Reference this when setting up `reference/meetings/MEETING_NOTES_SUMMARY.md` in a new toolkit, or when adding a new entry to an existing one.

**Location**: `reference/meetings/MEETING_NOTES_SUMMARY.md` — all meetings consolidated in a single file, newest entry at the top.

---

## File Header (use once, at the top of MEETING_NOTES_SUMMARY.md)

```markdown
# Meeting Notes Summary

All meetings consolidated in one file. Newest entry at the top.
Last updated: [YYYY-MM-DD]

---
```

---

## Standard Entry Format

Copy this block for each new meeting. Add it at the top of the file, above the previous entry.

```markdown
## Meeting [##] — [YYYY-MM-DD] — [Meeting title or topic]

**Attendees**: [Names and roles — e.g. "Edgar (Slalom), Sarah (AFC Finance), Mike (AFC IT)"]  
**Transcript**: [Granola link or "No transcript available"]  
**Notes source**: [Granola / Personal notes / Both]

### Key Decisions

- [Decision 1 — be specific. "Approved" or "Agreed to" rather than "Discussed"]
- [Decision 2]
- [Decision 3]

### Action Items

| Item | Owner (role) | Due |
|---|---|---|
| [Action 1] | [Role] | [Date or "TBD"] |
| [Action 2] | [Role] | [Date or "TBD"] |

### Notes

[Anything important that does not fit the above — room dynamics, open questions raised
but not resolved, context that may matter later. Keep this brief.]

---
```

---

## Granola vs Personal Notes

| Use | When |
|---|---|
| **Granola** | Structured takeaways, action items, decisions. Good for sharing. |
| **Personal notes** | Nuance, room dynamics, who pushed back, what was said off the record. Not for sharing. |

Use both for important meetings. Granola is the shareable record; personal notes are your context.

---

## When to Suggest a Granola Prompt

During a session, suggest a Granola prompt when:

- A decision from a past meeting is unclear and the exact wording matters
- A stakeholder's specific statement needs to be quoted accurately
- Something needs to be verified against a transcript before acting on it
- Two people remember a past agreement differently

Do not suggest Granola prompts for routine lookups or when the answer is already in `MEETING_NOTES_SUMMARY.md`.

**Example Granola prompt suggestions**:

```
"The threshold we agreed to isn't documented clearly here — do you want to pull the
Granola notes from the March 14 meeting to confirm the exact number?"

"Before I draft the scope section, it might be worth checking the Granola transcript
from the kickoff — the client's exact framing of the problem would be useful here."
```

---

## Numbering Convention

Number meetings sequentially from 01. If meetings span multiple tracks or workstreams, prefix with the track abbreviation:

```
Meeting 01 — Project kickoff
Meeting 02 — Technical deep dive
AP-01 — AP invoice monitoring kickoff
FIN-01 — Finance use cases scoping
```

Use whichever convention matches the project. Be consistent.

---

**Template version**: 1.0  
**Last updated**: 2026-06-17
