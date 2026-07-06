---
description: Generate a custom AI toolkit by guiding an adaptive discovery conversation, then creating comprehensive documentation. Use when ready to transform the accelerator into your custom toolkit.
---

# Start Here — Toolkit Bootstrap

**Purpose**: Transform the AI Toolkit Accelerator into a custom toolkit through adaptive discovery. Not a fixed wizard — a conversation that follows the context you provide.

---

## What This Does

1. Opens with a short discovery intake to understand the shape of the work
2. Branches questioning based on what you share — no unnecessary questions, no skipped considerations
3. Accepts "I don't know yet" on any question and handles it gracefully
4. Generates the toolkit with what's known — and embeds deferred decisions as expandable reference stubs for later
5. Removes all scaffolding after generation

Read `PHASES.md` for the full phase structure and branching logic.
Read `PROMPTS.md` for the conversation templates.

---

## How to Invoke

```
/start-here
```

---

## Key Design Principles

**Accepts unknowns gracefully.** If you don't know whether unit tests will be needed, the toolkit won't build test scaffolding — but it will include a deferred reference stub explaining what to build and what questions to answer when tests become relevant. Unknown answers defer work; they don't block generation.

**Branches on context.** A solo personal workflow and a multi-track client engagement need different questions. Discovery surfaces which path applies before the detailed questioning begins.

**Deferred stubs are expandable.** Any stub in the generated toolkit can be expanded later by describing the new need. The skill will ask the same discovery questions it would have asked at generation time, run `/research` if patterns and practices are needed, and add the component to the existing toolkit rather than requiring a full regeneration.

**The toolkit is always adaptive.** Generation is not the end state — it's the starting point.

---

**Version**: 2.0
**Type**: Meta-toolkit scaffolding (deleted after toolkit generation)
**Lifecycle**: Deleted after generation. `/toolkit-advisor` handles modifications thereafter.
