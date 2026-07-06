---
description: Session initialization skill. Reads the current state of the toolkit — active tasks, project context, and latest meeting notes — then gives a concise orientation summary before asking what to work on. Use at the start of any session.
---

# Brief — Session Initialization

You are starting a new Claude Code session for this toolkit. Your job is to read the current state and give a confident, concise orientation before asking what to work on.

---

PRE-FLIGHT — Run every check below before producing the summary.

COMMUNICATION RULE: Keep all pre-flight messages to 1-2 lines. Hard stops: state problem + fix in one sentence. Soft checks: one line question. Confirmations: one medium line. Shift to normal conversation if the developer asks questions — return to brief responses once resolved.

STEP 1 — Locate docs/ACTION_ITEMS.md
If not found: "docs/ACTION_ITEMS.md is missing — create it before running /brief."
Hard stop.

STEP 2 — Locate docs/PROJECT_CONTEXT.md
If not found: "docs/PROJECT_CONTEXT.md is missing — create it before running /brief."
Hard stop.

STEP 3 — Locate reference/meetings/MEETING_NOTES_SUMMARY.md
If not found: note the absence in the summary but do not stop. The summary can proceed without it.
If found: read the most recent entry. If the file has a status block or key decisions section at the top, read that first — it is the fastest path to current state.

STEP 4 — Read all three files silently. Do not output anything yet.

---

SUMMARY FORMAT

After reading, produce a summary in this format. No headers, no preamble, no "Here is your brief:". Start directly with the bullet list.

- **Status**: [One sentence on where the engagement stands overall — active phase, current focus]
- **Open blockers**: [List any items from ACTION_ITEMS.md marked as blocked or high priority — if none, say "No active blockers"]
- **Priority tasks**: [2-3 highest priority items from ACTION_ITEMS.md]
- **Last meeting**: [Date and one sentence on the most important decision or outcome from the latest MEETING_NOTES_SUMMARY entry — if no meeting notes, say "No meeting notes on file"]
- **Context note**: [One sentence from PROJECT_CONTEXT.md that is most relevant to current priorities — skip if nothing stands out]

Keep the entire summary to 5-8 bullets. If the context files are sparse, the summary should be shorter, not padded.

After the summary, ask on a new line:

"What do you want to work on?"

---

BEHAVIOR NOTES

- Do not narrate the reading process. Read silently, then produce the summary.
- Do not add section headers, bold titles, or formatting beyond the bullet list.
- If ACTION_ITEMS.md has many items, surface only the highest priority ones — do not dump the full list.
- If the meeting notes file has multiple entries, read only the most recent one.
- Scale conservatively on smaller context models — shorter is better than longer.
- If the developer asks a follow-up question after the summary, answer it in full, then return to brief mode.
