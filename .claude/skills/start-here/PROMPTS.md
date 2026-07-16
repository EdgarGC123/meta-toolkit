# Start Here — Conversation Templates

These are the prompt shapes for each phase. Adapt based on context — do not read these as scripts.

---

## Opening (Phase 0 → 1)

```
Starting toolkit generation.

I'll ask a short set of discovery questions first, then go deeper based on what you share.
No need to have everything figured out — "I don't know yet" is a valid answer and I'll 
handle it by building a deferred stub you can expand later.

First question: who is this toolkit for?

1. You personally (solo workflow)
2. Your team (internal shared use)
3. A client engagement (external delivery)
4. Not sure yet
```

---

## Phase 1 Follow-Ups

After Q1, pace one question at a time. Do not batch all five at once.

**After solo answer:**
```
Got it — a personal workflow. That shapes how much scaffolding we'll build in.

What does "done" look like for one complete run of this toolkit?
(One or two sentences — this anchors the phase design.)
```

**After team/client answer:**
```
Understood — [team use / client engagement]. That means we'll build in 
[internal/client separation / delivery platform questions / track structure] 
when we get there.

What does "done" look like for one complete run? One or two sentences.
```

---

## Analysis Presentation (Phase 2)

After receiving the workflow description:

```
Here's what I'm seeing in your description:

**Workflow type**: [Analysis / Creation / Processing / Decision]

**Proposed phase structure** ([N] phases):
1. [Phase Name] — [one-line objective]
2. [Phase Name] — [one-line objective]
...

**Patterns detected**:
[If skills applicable:] • [skill-name]: [why it fits]
[If none:] • No reusable patterns detected — straight custom workflow

**Plugins that may apply**:
[If any:] • [plugin-name]: [why it was flagged]
[If none:] • None identified from the description

Does this structure look right, or do you want to adjust before we go phase by phase?
```

---

## Per-Phase Detail (Phase 3)

```
Phase [N]: [Phase Name]

Objective — one sentence: what does this phase accomplish?
```

Wait. Then:

```
What does this phase start with? (Files, prior phase output, user input, etc.)
```

Wait. Then:

```
What are the concrete steps inside this phase?
(Comma-separated or numbered — whatever's easier.)
```

Wait. Then:

```
How does the agent know this phase is done? 
(The success signal — what it checks before moving on.)
```

If the answers make the next sub-question self-evident, confirm and skip:
```
From what you've described, I'll infer [X] — does that sound right?
```

---

## Deferred Stub Confirmation (Phase 5)

```
Before we generate, I want to confirm the deferred items:

[List each one with a one-line description]

For each of these I'll create a `.deferred/[topic].md` stub — a file that explains 
what would be built, what questions to answer first, and how to expand it when you're 
ready. The stubs will be visible in your CLAUDE.md so they surface at the start of 
every session.

Want to answer any of these now, or park them all?
```

---

## Final Confirmation Summary (Phase 6)

```
Here's the full structure:

TOOLKIT: [Name]
PURPOSE: [One sentence]
WORKFLOW TYPE: [Type]
AUDIENCE: [Solo / Team / Client]

PHASES ([N]):
  1. [Name] — [objective]
  2. [Name] — [objective]
  ...

SKILLS INCLUDED:
  [list or "None"]

PLUGINS INCLUDED:
  [list or "None"]

DELIVERY PLATFORM: [platform or "Not yet determined"]
TRACKS: [track names or "Single track"]

DEFERRED (expandable later):
  [list of stubbed topics, or "None"]

ADVANCED:
  Testing: [framework or "Deferred" or "Not applicable"]
  Hooks: [types or "Not enabled"]
  Path-scoped rules: [count or "Not enabled"]
  Templates: [count or "None"]

Ready to generate?
```

If user says no: ask what to change, make adjustments, re-confirm.

---

## Generation Progress (Phase 7)

```
Generating...

✓ Directory structure
✓ CLAUDE.md (session guide)
✓ README.md
✓ GETTING_STARTED.md
✓ workflow/WORKFLOW.md
✓ workflow/CONFIG.md
✓ AI_BEHAVIOR_GUIDELINES.md
✓ /brief skill
✓ docs/ACTION_ITEMS.md
✓ docs/PROJECT_CONTEXT.md
✓ reference/meetings/MEETING_NOTES_SUMMARY.md
[if skills:] ✓ Skills: [names]
[if plugins:] ✓ Plugins: [names]
[if deferred:] ✓ Deferred stubs: [count] topics parked for later
[if templates:] ✓ Templates: [names]
[if testing:] ✓ Testing structure: [framework]
[if hooks:] ✓ Hooks configuration
[if rules:] ✓ Path-scoped rules

Cleaning up scaffolding...
✓ Removed bootstrap artifacts
✓ Removed .meta/
✓ Removed start-here skill
✓ Removed DESIGN_PHILOSOPHY.md
✓ Removed START_HERE.md
```

---

## Completion (Phase 8)

```
[Toolkit Name] is ready.

GENERATED:
  [N] workflow phases
  [List of skills, plugins, templates if any]
  Session orientation (/brief)
  Behavioral guidelines

[If deferred stubs:]
DEFERRED (visible in CLAUDE.md, expandable when ready):
  [List of stub topics]

NEXT STEPS:
  1. Run /brief to orient the first session
  2. Review workflow/WORKFLOW.md to verify the phase design
  3. Fill in docs/PROJECT_CONTEXT.md and docs/ACTION_ITEMS.md

To modify this toolkit later: /toolkit-advisor
To expand a deferred topic: describe the need in a new session

[Git detach — include exactly one of the following based on the rm -rf .git result in Step 1:]

[If .git was successfully removed:]
  Git history and remote connection removed. This toolkit is clean —
  run `git init` when you're ready to start your own repository.

[If .git still exists after removal attempt:]
  ⚠️ Git detach incomplete — .git still exists in this directory.
  Your toolkit is otherwise ready, but it remains connected to the
  generator's remote repository. Run `rm -rf .git` manually,
  then `git init` to start fresh.
```

---

## Expanding a Deferred Stub (Post-Generation)

When a user describes a need that matches a deferred stub — or any new need that wasn't covered at generation time:

```
Let me pull up what we deferred on [topic].

[Read .deferred/[topic].md if it exists]

Here are the questions we parked:
[List from stub]

Let's go through them now. First: [Q1]
```

After the questions are answered, decide whether research would help before building:

```
[If patterns, examples, or best practices would meaningfully improve the output:]
Before I build this, let me pull in current patterns and practices.
Running /research on [specific focused query].

[Run /research]

Here's what's relevant: [brief synthesis — what applies to this toolkit]

Based on your answers[and the research], here's what I'll add:
[description of what will be generated]

Ready to proceed?

[If the answer is clear without research:]
Based on your answers, here's what I'll add:
[description]

Ready to proceed?
```

After generation:

```
[Topic] has been added.

Updated:
  ✓ [new files created]
  ✓ [any existing files that changed]
  ✓ CLAUDE.md — provenance section updated
  ✓ .deferred/[topic].md — stub removed

The toolkit now includes [component].
```

---

## "I Don't Know Yet" Response

For any question where the user answers with a variant of "not sure" or "maybe later":

```
No problem — I'll park [topic] as a deferred stub. When you're ready to add it, 
describe the need in a new session and I'll walk through the same questions then.
```

Then continue to the next question. Never re-ask a deferred question in the same session.

---

**Version**: 2.0
**Last Updated**: 2026-07-03
