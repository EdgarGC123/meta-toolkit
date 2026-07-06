# Prompt Engineering Standards

**Purpose**: How to think about and build prompts as composable, reusable artifacts — not one-off chat interactions.

---

## The Shift: Prompts as Composable Artifacts

Stop having one-off chat interactions with the LLM. Instead, design structured prompts that any developer can invoke and get consistent, repeatable results.

A prompt is ready when:
- Any developer can invoke it and get the same output
- It has defined success criteria (what "done" looks like)
- It has defined guardrails (what should NOT happen)
- It has a verification step before executing
- It has a feedback loop (run → parse output → fix → rerun)

---

## Never Write Prompts by Hand

Describe what you are trying to accomplish. Ask the LLM to generate the prompt. Iterate on the prompt with the LLM.

This applies to all prompts — skill prompts, agent prompts, workflow prompts. The LLM understands its own instruction format better than most developers do. Use it.

---

## Self-Updatable Prompts

If a prompt does something unexpected, instruct it to revise itself. Build this into your workflow:

"If the output does not match what I expected, update this prompt to correct the behavior."

This creates a feedback loop that improves prompt quality over time without manual re-engineering.

---

## Prompt Testing with Gold Standards

For prompts that generate artifacts (PRDs, reports, solution docs):

1. Run the prompt once and produce a good output
2. Save that output as a gold standard reference file in a `/prompt-tests` folder
3. Add a step to the prompt: compare output to the reference file
4. If divergence: either update the reference or fix the prompt

The gold standard file makes regression visible. Without it, prompt drift is invisible until a client notices.

---

## Identify Repetitive Tasks First

Before building a prompt, ask: "Am I doing this same thing over and over?"

If yes — that is a candidate for a composable prompt. Common candidates:
- Implementing a feature from a story
- Fixing a bug from a ticket
- Generating a PRD from requirements
- Generating release notes from a commit log
- Running coverage analysis on a module

If you can describe the task in a consistent structure, you can build a reusable prompt for it.

---

## Prompt Anatomy Checklist

Every production prompt should answer these questions:

| Question | How to address |
|---|---|
| What is this? | One identity sentence at the top |
| What input does it need? | Explicit pre-flight checks with hard stops |
| What should it confirm before running? | Confirmation step before executing |
| What should it produce? | Fully specified output format |
| What should it NOT do? | Explicit guardrails or out-of-scope statements |
| What happens if input is wrong? | Specific error messages with how-to-fix |
| How does the user know it worked? | Success criteria or verification step |

---

## Composing Prompts into Workflows

Individual prompts can be chained into workflows:

```
Prompt A: Extract requirements from transcript
  → output: structured requirements doc
  
Prompt B: Generate PRD from requirements doc
  → input: structured requirements doc
  → output: PRD

Prompt C: Generate epics from PRD
  → input: PRD
  → output: epic list with acceptance criteria
```

Each prompt is self-contained and testable independently. The workflow is just the chaining logic.

---

## Common Failure Modes

**Failure: AI finds the shortest path**
Cause: No success criteria or guardrails defined.
Fix: Add explicit "done looks like X, do NOT do Y" to the prompt.

**Failure: Output is inconsistent across runs**
Cause: Prompt relies on AI defaults rather than specifying format.
Fix: Fully specify output format in the prompt.

**Failure: Prompt works once but drifts over time**
Cause: No gold standard to compare against.
Fix: Save a good output as a reference file.

**Failure: Developer cannot reproduce the output another developer got**
Cause: Prompt lives in a chat history, not a shared file.
Fix: Commit prompts to the repo like code.

---

**Version**: 1.0
**Last Updated**: 2026-07-03
