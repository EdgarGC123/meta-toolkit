# Skills Directory

This directory is for **skills** - reusable workflow patterns you create.

---

## What Goes Here

After you've built a few toolkits, you'll notice workflow patterns that repeat. Extract those patterns as skills for reuse.

**Examples of what skills might be**:
- Multi-phase analysis pattern
- Information extraction workflow
- Content generation approach
- Decision-making framework

---

## Creating Your First Skill

When you're ready to create a reusable skill:

1. See `.meta/SKILL-GUIDE.md` for detailed instructions
2. Create `.meta/skills/your-skill-name/`
3. Define phase structure and prompts
4. `/start-here` will detect it automatically on the next generation

---

## Current Skills

| Skill | What it does |
|---|---|
| `iterative-processing/` | Starter reference pattern for multi-step iterative workflows |

## Base Skills (invokable via Claude Code)

| Skill | Location | What it does |
|---|---|---|
| `brief` | `.meta/base-skills/brief/` | Session initialization — reads current state and orients the session |
| `research` | `.meta/base-skills/research/` | Targeted technical research with sourced findings |
| `solution-writer` | `.meta/base-skills/solution-writer/` | Produces solution planning doc (internal) and solution doc (client-facing) from research findings |
| `add-checkpoint` | `.meta/base-skills/add-checkpoint/` | Knowledge persistence — updates all reference files with session findings |

**Workflow**:
1. Generate toolkit → use it → notice repeated patterns
2. Extract workflow pattern as skill
3. Add to this directory
4. Apply to future toolkits

---

**Start with your first toolkit. Skills emerge from experience.**
