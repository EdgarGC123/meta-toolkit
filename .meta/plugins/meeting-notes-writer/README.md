# Plugin: Meeting Notes Writer

**Pattern**: Prompts-only
**Invocation type**: On-demand or workflow-embedded (ask at generation time)
**Status**: Starter — customize the prompt to match your team's preferred format

---

## What It Does

Converts raw meeting notes, bullet points, or a transcript excerpt into structured meeting notes. Output follows the toolkit's `MEETING-NOTES-SUMMARY.md` format by default but can be adapted.

## When to Use

- After a meeting, before adding to MEETING-NOTES-SUMMARY.md
- When you have rough notes and want them structured quickly
- Works with Granola transcripts, voice memo transcriptions, or hand-typed bullets

## Starting Point Prompt

See `prompts/generate.prompt.md` — adapt the output format to match your team's conventions.

## Invocation Type Guidance

- **On-demand**: best if meetings are ad-hoc and you process notes manually
- **Workflow-embedded**: best if every session ends with a "document this meeting" step
