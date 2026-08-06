---
description: Structural rules for editing PHASES.md, SKILL.md, and PROMPTS.md files in the generator
paths:
  - ".claude/skills/**"
---

# Phases and Skills Rules

## Shell Command Rule

Always use **relative paths** in any shell commands written into PHASES.md or skill files. Claude Code's safety layer blocks `rm -rf` on absolute paths regardless of `settings.json`. All destructive commands must use paths relative to the project root (e.g. `rm -rf .meta/` not `rm -rf /Users/edgar/.../`).

---

## PHASES.md Structure Requirements

Every phase must have:
- **Objective** — one sentence
- **Actions** — specific, not vague ("read package.json" not "analyze the codebase")
- **Validation checkpoint** — how to know the phase is done
- **Questions to ask user** — with branch logic for each answer

Phase count guidelines: 2-3 simple, 4-5 medium, 6-8 complex. 9+ is a signal to split the skill.

## Skill Self-Sufficiency Test

A skill must work even if the user never read any other documentation. Before finishing a skill, verify:
- [ ] Identity sentence tells Claude exactly what role to play
- [ ] All required inputs are defined
- [ ] Success criteria are explicit
- [ ] Output format is fully specified
- [ ] Edge cases are handled (what to do when input is missing/ambiguous)
- [ ] No external knowledge assumed
- [ ] Works standalone without referencing other docs

## SKILL.md Required Frontmatter

```yaml
---
description: [trigger language — what scenario causes this skill to be used]
---
```

The `description:` field is how Claude decides when to invoke the skill. Write it as the sentence a user would say, not as a summary of what the skill does.

## Durability Rules for Skills

Never hardcode in SKILL.md or PHASES.md:
- Specific meeting numbers ("Meeting 7") — use "the most recent entry"
- Specific dates — use "read ACTION-ITEMS.md for current status"
- Personal names in forward-looking instructions — use role names
- Model version names — use "the current model" unless a specific capability requires it

## PROMPTS.md Division of Labor

- `PHASES.md` = what to do (logic, branching, validation)
- `PROMPTS.md` = how to present it (templates, tone, transition language)

Never put execution logic in PROMPTS.md. Never put conversation templates in PHASES.md.
