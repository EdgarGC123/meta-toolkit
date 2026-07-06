# Start Here

**Welcome to the AI Toolkit Generator.**

This generates a custom AI workflow toolkit tailored to your specific needs through an adaptive discovery conversation — not a fixed wizard.

---

## How to Start

```bash
git clone https://github.com/[repo]/ai-toolkit-accelerator my-toolkit
cd my-toolkit
/start-here
```

Claude will guide you through a short intake, then branch into the questions that are actually relevant for your use case. The moment you run `/start-here`, a background process removes the git history and remote connection — so by the time generation completes, the toolkit is a clean slate ready for `git init` as your own repository.

---

## What to Expect

The process opens with a few discovery questions — who this is for, what "done" looks like, whether code or client deliverables are involved. Based on your answers, it goes deeper only where it matters.

**You don't need to have everything figured out.** If you don't know whether unit tests will be part of the work, say so. The toolkit will generate a deferred stub — a reference placeholder that explains exactly what to build and what questions to answer when you're ready. Later, when the need becomes real, describe it in a new session and the toolkit expands itself.

---

## What Gets Generated

### Always included
- `CLAUDE.md` — session guide, run `/brief` at the start of every session
- `workflow/WORKFLOW.md` — your phases with detailed guidance
- `workflow/CONFIG.md` — toolkit settings
- `AI_BEHAVIOR_GUIDELINES.md` — behavioral rules for all agents
- `README.md` and `GETTING_STARTED.md`
- `.claude/skills/` — `/brief` (session orientation), `/research` (technical research), `/solution-writer` (planning + client docs)
- `docs/ACTION_ITEMS.md`, `docs/PROJECT_CONTEXT.md`, `reference/meetings/MEETING_NOTES_SUMMARY.md`

### Conditionally included (based on your answers)
- Skills and plugins matched to your workflow
- Per-track folder structure (if multi-track engagement)
- Testing infrastructure (if code is involved)
- Delivery platform setup (if client-facing deliverables)
- Path-scoped rules, validation hooks, output templates

### Deferred (expandable later)
- Any topic you answered "not sure yet" becomes a `.deferred/[topic].md` stub
- Stubs surface in `CLAUDE.md` so they're visible every session
- Expand any stub by describing the need — the process runs the same discovery questions and integrates the component

### Cleanup (automatic)
After generation, all scaffolding is deleted: `.meta/` (including base-skills source templates — already copied), `.claude/skills/start-here/`, `START_HERE.md`. The `.git` directory is also removed. Only your toolkit remains — a clean directory with no git history or remote ties.

---

## After Generation

- Run `/brief` at the start of every session
- Use `/toolkit-advisor` to modify the toolkit as the engagement evolves
- Describe any deferred topic when you're ready to expand it — the toolkit will grow to meet it

---

## Need Help?

- Read `DESIGN_PHILOSOPHY.md` to understand what's baked into the toolkit and why
- Read `.meta/ARCHITECTURE.md` for how the system works
- `/help` for Claude Code help

---

**Version**: 4.0
**Updated**: 2026-07-03
