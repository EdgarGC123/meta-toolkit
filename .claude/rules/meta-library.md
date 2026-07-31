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
- `ARCHITECTURE.md` — system architecture and patterns
- `AI-BEHAVIOR-GUIDELINES.md` — behavioral contract for all agents
- `AGENTIC-PATTERNS.md` — reusable workflow patterns
- `SKILL-GUIDE.md`, `PLUGIN-GUIDE.md`, `PHASES-GUIDE.md`, `PROMPTS-GUIDE.md` — builder guides
- `CLAUDE-CODE-SKILLS-REFERENCE.md` — skill frontmatter and discovery rules

## Durability Rule

Never hardcode in `.meta/` files:
- Specific dates or meeting counts
- Personal names in forward-looking instructions (use role names)
- Model version names unless a specific capability requires it
- Blockers or decisions (those belong in `docs/`)
