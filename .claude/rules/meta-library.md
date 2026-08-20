---
description: Naming conventions, file structure rules, and landmark file standards for the .meta/ library
paths:
  - ".meta/**"
---

# Meta Library Rules

## File Naming Convention

| File type | Convention | Examples |
|---|---|---|
| Regular files | `kebab-case.md` | `feature-notes.md` |
| Landmark aggregate files | `ALL-CAPS-KEBAB.md` | `PROJECT-CONTEXT.md`, `ACTION-ITEMS.md` |
| Generator meta files | `ALL-CAPS-KEBAB.md` | `SKILL-GUIDE.md`, `PHASES-GUIDE.md`, `PLUGIN-GUIDE.md` |

**Rule**: Underscores are not used anywhere in this repo. If you see a filename with underscores, it is stale and should be updated.

## Folder Rename Rule

If any folder in `.meta/` is renamed, update all path references in the same session:
- `CLAUDE.md` Key Locations table
- `PHASES.md` Meta Library Map
- Any `.meta/` file that references the renamed folder by path

## Three Skill Locations

| Location | Purpose | Executable? |
|---|---|---|
| `.meta/skills/` | Reference patterns — copied to toolkit `skills/` when selected | No |
| `.meta/base-skills/` | Copied into every generated toolkit's `.claude/skills/` | No (until copied) |
| `.claude/skills/` | Live commands — invokable as `/skill-name` right now | Yes |

## Landmark Files in .meta/

These are the authoritative references — one per topic, never duplicated:
- `ARCHITECTURE.md` — system architecture, conventions, and context management patterns
- `AI-BEHAVIOR-GUIDELINES.md` — behavioral contract for all agents
- `AGENTIC-PATTERNS.md` — reusable workflow patterns and interaction types
- `SKILL-GUIDE.md` — skill structure, A-J build sequence, platform decision matrix
- `PLUGIN-GUIDE.md` — plugin structure and patterns
- `PHASES-GUIDE.md` — how to write PHASES.md files for skills
- `PROMPTS-GUIDE.md` — how to write PROMPTS.md files for skills
- `CLAUDE-CODE-SKILLS-REFERENCE.md` — skill and rules file frontmatter, discovery rules
- `DISCOVERY-PIPELINE.md` — requirements extraction from raw artifacts
- `MODEL-SELECTION.md` — current model table and when-to-use rules
- `PROMPT-ENGINEERING.md` — prompt design principles and composable artifact patterns
- `TESTING-GUIDE.md` — conditional testing scaffold generation
- `SOLUTION-DOC-TEMPLATE.md` — client-facing deliverable structure
- `MEETING-NOTES-TEMPLATE.md` — meeting notes entry format
- `PERMISSIONS-TEMPLATE-README.md` — permission layer system and merge rules
- `BEDROCK-COST-GUIDE.md` — Bedrock setup, caching mechanics, cost patterns, hybrid model workflow

## Durability Rule

Never hardcode in `.meta/` files:
- Specific dates or meeting counts
- Personal names in forward-looking instructions (use role names)
- Model version names unless a specific capability requires it
- Blockers or decisions (those belong in `docs/`)
