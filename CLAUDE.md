# Claude Code Session Guide — AI Toolkit Generator

This is the session guide for working **on the generator itself** — maintaining it, extending it, and generating new toolkits from it. It is not a generated toolkit session guide.

---

## What This Repo Is

The AI Toolkit Generator is a scaffolding system. When you run `/start-here`, it generates a custom toolkit for a specific engagement or workflow, then deletes itself from that copy. The original generator remains untouched as your source library.

---

## Key Locations

| What | Where |
|---|---|
| Executable skills here | `.claude/skills/start-here/` (generation), `.claude/skills/research/` (copy of the base skill, for verifying claims while maintaining the generator) |
| Research working directory | `research/` — not committed, deleted when planning concludes |
| Path-scoped rules (auto-load by file path) | `.claude/rules/meta-library.md` — loads when editing `.meta/**`; `.claude/rules/phases-skills.md` — loads when editing `.claude/skills/**` |
| Generation phase logic and meta library map | `.claude/skills/start-here/PHASES.md` |
| Toolkit-operational skills (source) | `.meta/base-skills/` — brief, research, solution-writer, add-checkpoint |
| Lifecycle hook templates (not yet wired into generation) | `.meta/base-hooks/` — starter scripts, settings layers, full 30-event reference |
| Architecture and guides | `.meta/ARCHITECTURE.md`, `DESIGN_PHILOSOPHY.md` |
| Behavioral rules shipped to all toolkits | `.meta/AI-BEHAVIOR-GUIDELINES.md` |
| Model-tier behavior rules (new — not yet in guidelines) | `.meta/MODEL-BEHAVIOR-RULES.md` |
| Bedrock setup, caching, cost patterns, hybrid workflow | `.meta/BEDROCK-COST-GUIDE.md` |
| Permission layer templates | `.meta/settings.template.json`, `settings.research.json`, `settings.developer.json`, `settings.diagnostic.json` — merged into `.claude/settings.json` at generation time based on what the toolkit needs |
| Permission merge guide | `.meta/PERMISSIONS-TEMPLATE-README.md` |
| Accumulation library | `.meta/plugins/`, `.meta/skills/`, `.meta/templates/` |
| Skill pattern reference | `.meta/skills/iterative-processing/` |
| Builder guides (skill, plugin, phases, prompts) | `.meta/SKILL-GUIDE.md`, `.meta/PLUGIN-GUIDE.md`, `.meta/PHASES-GUIDE.md`, `.meta/PROMPTS-GUIDE.md` |
| Generation reference docs | `.meta/AGENTIC-PATTERNS.md`, `.meta/PROMPT-ENGINEERING.md`, `.meta/DISCOVERY-PIPELINE.md`, `.meta/MODEL-SELECTION.md`, `.meta/CLAUDE-CODE-SKILLS-REFERENCE.md` |

---

## Folder Rename Rule

If any folder in this generator is renamed, update path references in this file and in `.claude/skills/start-here/PHASES.md` in the same session.

---

## Shell Command Conventions

**Always use relative paths** when running shell commands in this repo. Claude Code's safety layer blocks `rm -rf` on absolute paths regardless of `settings.json`. All destructive commands must use paths relative to the project root.

Good: `rm -rf .meta/` `rm -f FUTURE-WORK.md` `mv old-name new-name`
Blocked: `rm -rf /Users/edgar/.../some-folder`

**Confirm `pwd` before any destructive operation** — relative paths only work correctly when you are in the project root.

---

## Working on the Generator

**Adding a new base skill** (one that ships into every generated toolkit):
1. Build and test the skill under `.meta/base-skills/[skill-name]/`
2. Update the generation order in `.claude/skills/start-here/PHASES.md`
3. Update the "Skills Baked Into Every Generated Toolkit" section in `README.md`

**Adding to the accumulation library** (selectively included at generation time):
- Plugins → `.meta/plugins/[name]/`
- Workflow patterns → `.meta/skills/[name]/`
- Output templates → `.meta/templates/[name].template.md`

**Updating behavioral rules**:
- Edit `.meta/AI-BEHAVIOR-GUIDELINES.md` — changes propagate to all future generated toolkits
- Edit `.meta/base-skills/research/SKILL.md` for research behavior
- Edit `.meta/base-skills/brief/SKILL.md` for session orientation behavior

**Generating a new toolkit**:
- Copy this generator to a new directory, open it in Claude Code, run `/start-here`

---

## What NOT to Do Here

- Do not run `/brief` or `/add-checkpoint` — both expect `docs/ACTION-ITEMS.md` and `docs/PROJECT-CONTEXT.md`, which do not exist here. Read this file for orientation instead.
- Do not run `/solution-writer` — it is toolkit-operational, with no applicable client-deliverable context in the generator itself
- Do not modify `.meta/` files in a generated toolkit copy — changes there affect only that copy and will be deleted with `.meta/` after generation

**`/research` is available here and actively used.** A copy lives at `.claude/skills/research/` so it is invokable while working on the generator. Research findings are saved to `research/` — a working directory that is **not committed** and gets deleted when planning work concludes. Use it for verifying claims before baking them into `.meta/` docs.

---

