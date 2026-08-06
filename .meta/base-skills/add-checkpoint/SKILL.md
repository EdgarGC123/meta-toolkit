---
description: Knowledge persistence skill. Reviews the current session and updates all relevant toolkit reference files — codebase maps, architecture notes, project context, action items — so the next session starts warm. Run whenever meaningful progress has been made.
when_to_use: After local environment setup, after exploring a new area of the codebase, after completing or advancing a story, after a key decision, or whenever the session has produced knowledge worth preserving. Run before closing a session with important findings.
---

# Add Checkpoint — Knowledge Persistence

You are capturing what was learned this session and writing it into the toolkit's reference files. Your job is to extract durable knowledge from the conversation and update the right files so the next session starts with full context rather than re-deriving what was already figured out.

The test for whether something belongs in a reference file: "If Claude had to figure this out again in a future session, would it take more than a few seconds?" If yes, write it down.

---

PRE-FLIGHT — Run every check below before updating anything.

COMMUNICATION RULE: Keep all pre-flight messages to 1-2 lines. Hard stops: state problem + fix in one sentence. Soft checks: one line question. Shift to normal conversation if the developer asks questions — return to brief responses once resolved.

STEP 1 — Locate docs/ACTION-ITEMS.md and docs/PROJECT-CONTEXT.md
If either is missing: "Required file is missing — create it before running /add-checkpoint."
Hard stop.

STEP 2 — Scan for reference files (do not stop if absent)
Check for: reference/*/APP-CONTEXT.md, reference/*/ARCHITECTURE.md, reference/meetings/MEETING-NOTES-SUMMARY.md
Note which ones exist — update only the ones that are present and relevant to this session's findings.

STEP 3 — Review the conversation silently
Do not output anything yet. Extract findings across these categories:
- **Story progress** — active ticket, current phase, what was confirmed or implemented, what's next
- **Codebase findings** — files, components, services, routes, patterns newly discovered or clarified
- **Setup or environment knowledge** — local dev steps, env vars, tool versions, gotchas, commands
- **Architecture or conventions** — patterns confirmed, decisions made, how something works
- **Blockers or open questions** — anything unresolved the next session should pick up

STEP 4 — Apply the priority filter before writing anything
Only write findings that pass ALL of these:
- Would save meaningful time in a future session (not obvious from reading the code)
- Is durable — will still be correct in future sessions without needing updates
- Is not already in the file

Skip: one-off interaction details, things directly derivable from the code, speculative or unconfirmed findings.

---

## Which Files to Update

**Always check and update if relevant:**
- `docs/ACTION-ITEMS.md` — update active story status, add/remove blockers, mark completed work, note what's next
- `docs/PROJECT-CONTEXT.md` — add team/process knowledge, local dev setup, tooling, env vars, constraints discovered

**Update if codebase was explored (update whichever reference files exist):**
- `reference/[name]/APP-CONTEXT.md` — new areas explored: pages, components, routes, services, where things live
- `reference/[name]/ARCHITECTURE.md` — confirmed patterns: state management, auth flow, data layer, conventions

**Update if team context emerged:**
- `reference/meetings/MEETING-NOTES-SUMMARY.md` — add an entry if decisions, priorities, or team updates were discussed

If a reference file doesn't exist yet and the session surfaced meaningful codebase knowledge, note at the end of the confirmation that it would be worth creating.

---

## Writing Rules

- Lead with the fact, not the story — write what future Claude needs to know, not what happened
- Be specific: file paths, line numbers, exact env var names, exact command syntax where relevant
- Keep entries short — bullet points over paragraphs; one clear sentence beats three vague ones
- Check existing content before adding — do not duplicate what's already there
- Use absolute dates, not relative ones ("2026-08-06" not "today" or "this sprint")
- Never write things that will be wrong without an update — if a finding is provisional, say so explicitly

---

## After Updating

Produce a short confirmation (one paragraph):
- Which files were updated
- The single most important finding captured
- Anything intentionally skipped and why

Keep it brief. The detail is in the files.

---

## BEHAVIOR NOTES

- Do not narrate the update process. Work silently, then confirm at the end.
- Do not update files with speculative or unconfirmed information — label uncertain findings explicitly if they must be written.
- If the session produced no durable findings (pure conversation, no new knowledge), say so briefly rather than writing thin or redundant content.
- If a reference file path doesn't match the toolkit's actual structure, note the mismatch rather than writing to the wrong location.
- This skill updates existing files — it does not create new reference file types. If new reference files are needed, suggest them in the confirmation but do not create them without confirming with the developer.

---

## How This Differs from /brief and /rewind

`/brief` reads the current state to orient the session at the start. `/add-checkpoint` writes new knowledge at the end (or mid-session) to preserve it for next time. They are complementary: `/brief` loads context in, `/add-checkpoint` writes context out.

`/rewind` is a Claude Code built-in that restores code and conversation to any of the 100 most recent in-session checkpoints — useful for recovering from a bad change mid-session. `/add-checkpoint` is different: it persists knowledge across sessions by updating the toolkit reference files. Use `/rewind` for in-session recovery, `/add-checkpoint` for cross-session knowledge capture.
