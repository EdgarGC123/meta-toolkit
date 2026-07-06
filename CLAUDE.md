# Claude Code Session Guide — AI Toolkit Accelerator

This is the session guide for working **on the accelerator itself** — maintaining it, extending it, and generating new toolkits from it. It is not a generated toolkit session guide.

---

## What This Repo Is

The AI Toolkit Accelerator is a scaffolding system. When you run `/start-here`, it generates a custom toolkit for a specific engagement or workflow, then deletes itself from that copy. The original accelerator remains untouched as your source library.

---

## Key Locations

| What | Where |
|---|---|
| Only executable skill | `.claude/skills/start-here/` |
| Generation phase logic and meta library map | `.claude/skills/start-here/PHASES.md` |
| Toolkit-operational skills (source) | `.meta/base-skills/` — brief, research, solution-writer |
| Architecture and guides | `.meta/ARCHITECTURE.md`, `DESIGN_PHILOSOPHY.md` |
| Behavioral rules shipped to all toolkits | `.meta/AI_BEHAVIOR_GUIDELINES.md` |
| Permission layer templates | `.meta/settings.template.json`, `settings.research.json`, `settings.developer.json`, `settings.diagnostic.json` — merged into `.claude/settings.json` at generation time based on what the toolkit needs |
| Permission merge guide | `.meta/PERMISSIONS_TEMPLATE_README.md` |
| Accumulation library | `.meta/plugins/`, `.meta/skills/`, `.meta/templates/` |
| Skill pattern reference | `.meta/skills/iterative-processing/` |
| Builder guides (skill, plugin, phases, prompts) | `.meta/SKILL_GUIDE.md`, `.meta/PLUGIN_GUIDE.md`, `.meta/PHASES_GUIDE.md`, `.meta/PROMPTS_GUIDE.md` |
| Generation reference docs | `.meta/AGENTIC_PATTERNS.md`, `.meta/PROMPT_ENGINEERING.md`, `.meta/DISCOVERY_PIPELINE.md`, `.meta/MODEL_SELECTION.md` |

---

## Folder Rename Rule

If any folder in this accelerator is renamed, update path references in this file and in `.claude/skills/start-here/PHASES.md` in the same session.

---

## Working on the Accelerator

**Adding a new base skill** (one that ships into every generated toolkit):
1. Build and test the skill under `.meta/base-skills/[skill-name]/`
2. Update the generation order in `.claude/skills/start-here/PHASES.md`
3. Update the "Skills Baked Into Every Generated Toolkit" section in `README.md`

**Adding to the accumulation library** (selectively included at generation time):
- Plugins → `.meta/plugins/[name]/`
- Workflow patterns → `.meta/skills/[name]/`
- Output templates → `.meta/templates/[name].template.md`

**Updating behavioral rules**:
- Edit `.meta/AI_BEHAVIOR_GUIDELINES.md` — changes propagate to all future generated toolkits
- Edit `.meta/base-skills/research/SKILL.md` for research behavior
- Edit `.meta/base-skills/brief/SKILL.md` for session orientation behavior

**Generating a new toolkit**:
- Copy this accelerator to a new directory, open it in Claude Code, run `/start-here`

---

## What NOT to Do Here

- Do not run `/brief` — there are no `docs/ACTION_ITEMS.md` or `docs/PROJECT_CONTEXT.md` here
- Do not run `/research` or `/solution-writer` — those are toolkit-operational skills with no applicable context in the accelerator itself
- Do not modify `.meta/` files in a generated toolkit copy — changes there affect only that copy and will be deleted with `.meta/` after generation

---

**Version**: 2.0
**Updated**: 2026-07-03
