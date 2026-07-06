# Claude Code Skills Reference

**Quick reference for creating skills that Claude Code can discover and execute via `/skill-name` commands.**

---

## Critical Requirements

### 1. Location

Skills MUST be in `.claude/skills/[skill-name]/`

**Correct**:
```
.claude/skills/start-here/SKILL.md       ✅
.claude/skills/research/SKILL.md         ✅
```

**Incorrect**:
```
skills/start-here/SKILL.md               ❌ Wrong location
.claude/start-here/SKILL.md              ❌ Missing skills/ subdirectory
.claude/skills/start-here/README.md      ❌ Wrong filename
```

---

### 2. Filename

Main file MUST be named `SKILL.md` (uppercase)

**Correct**: `SKILL.md` ✅  
**Incorrect**: `skill.md`, `Skill.md`, `README.md`, `skill_definition.md` ❌

---

### 3. YAML Frontmatter

SKILL.md MUST start with YAML frontmatter:

```yaml
---
description: Brief description of what this skill does and when to use it
---
```

**Optional frontmatter fields**:
```yaml
---
description: Required - what this skill does and when to use it
name: skill-name                    # Optional - display name; directory name is used for the /command
when_to_use: Additional context     # Optional - appended to description in skill listing
disable-model-invocation: true      # Optional - set true to prevent Claude from auto-invoking (manual only)
user-invocable: false               # Optional - set false to hide from / menu (Claude-only invocation)
allowed-tools: Read Bash(git *)     # Optional - tools Claude can use without approval when skill is active
disallowed-tools: Write             # Optional - tools removed from pool while skill is active
model: claude-sonnet-5              # Optional - model override for this skill's turn
effort: high                        # Optional - reasoning effort: low / medium / high / xhigh / max
context: fork                       # Optional - set to 'fork' to run skill in an isolated subagent
agent: Explore                      # Optional - subagent type when context: fork is set
paths:                              # Optional - glob patterns that limit when skill auto-activates
  - "src/auth/**"
---
```

---

## Discovery Locations

Claude Code checks these locations in order:

1. **`.claude/skills/<skill-name>/SKILL.md`** (project-specific) ← **Use this**
2. **`~/.claude/skills/<skill-name>/SKILL.md`** (personal, all projects)
3. **`<plugin>/skills/<skill-name>/SKILL.md`** (plugin skills)

---

## Complete Example

### Directory Structure

```
.claude/skills/start-here/
├── SKILL.md           # Required - main instructions
├── PHASES.md          # Optional - supporting structure
├── PROMPTS.md         # Optional - templates
└── examples/          # Optional - additional resources
    └── sample.md
```

### SKILL.md Template

```markdown
---
description: Generate a custom AI toolkit by analyzing your workflow and creating comprehensive documentation
when_to_use: Use when ready to transform the accelerator into your custom toolkit
---

# Start Here - Toolkit Bootstrap Skill

**Purpose**: Generate a custom AI toolkit based on your workflow description.

---

## What This Does

This skill transforms the AI Toolkit Accelerator into your custom toolkit by:
1. Analyzing your workflow description
2. Recommending appropriate structure
3. Asking clarifying questions
4. Generating complete toolkit
5. Cleaning up scaffolding files

---

## Instructions

[Your detailed instructions here...]

For complete phase structure, see [PHASES.md](PHASES.md)
For conversation templates, see [PROMPTS.md](PROMPTS.md)
```

---

## How to Invoke

Once the skill is in the correct location:

```
/skill-name
```

Example:
```
/start-here
/research
/brief
```

---

## Verification

To verify your skill is discoverable:

1. **List skills**: Type `/` and see if your skill appears in autocomplete
2. **Ask Claude**: "What skills are available?" 
3. **Run doctor**: Type `/doctor` to see loaded skills and their descriptions

---

## Common Mistakes

| Mistake | Problem | Fix |
|---------|---------|-----|
| `skills/start-here/SKILL.md` | Wrong location | Move to `.claude/skills/start-here/SKILL.md` |
| `SKILL.md` has no frontmatter | Not discoverable | Add `---\ndescription: ...\n---` at top |
| Named `README.md` not `SKILL.md` | Not recognized | Rename to `SKILL.md` |
| In root `.claude/` | Missing subdirectory | Must be `.claude/skills/<name>/` |

---

## Reference Skills vs Claude Code Skills

### Reference Skills (`.meta/skills/`)

**Purpose**: Reusable workflow pattern documentation — not executable

```
.meta/skills/iterative-processing/
├── README.md          # Pattern explanation
├── PHASES.md          # Pattern structure
└── PROMPTS.md         # Pattern templates
```

**Use**: Consulted during toolkit generation, copied to generated toolkit's `skills/` when selected

---

### Claude Code Skills (`.claude/skills/`)

**Purpose**: Executable commands via `/skill-name`

```
.claude/skills/start-here/
├── SKILL.md           # With YAML frontmatter (required)
├── PHASES.md          # Supporting docs (optional)
└── PROMPTS.md         # Supporting templates (optional)
```

**Use**: Invoke with `/start-here`

---

## When to Use Each

| Type | Location | Invokable? | Purpose | Example |
|------|----------|------------|---------|---------|
| **Reference Skill** | `.meta/skills/` | No | Pattern documentation | iterative-processing |
| **Claude Code Skill** | `.claude/skills/` | Yes | Executable command | /start-here, /research, /brief |

**Note**: A skill can exist in both locations if you want reference docs AND executable command

---

## Durability Rules

Skills are read by future sessions that have no memory of when they were written. These things go stale and should never be hardcoded in a SKILL.md:

- Specific meeting numbers or counts ("Meeting 7") — use "the most recent entry"
- Specific dates ("as of 2026-05-28") — use "read docs/ACTION_ITEMS.md for current status"
- Specific blockers or decisions — these belong in `docs/`, not in skills
- Model version names ("Sonnet 4.5") — use "the current model" unless a specific capability requires it
- Personal names in forward-looking instructions ("Edgar will confirm") — use role names ("the developer")

**Test**: If this skill were read 6 months from now, would any sentence be misleading? If yes, make it dynamic.

---

## Official Documentation

For complete Claude Code skills documentation, see:
https://code.claude.com/docs/en/slash-commands

---

**Version**: 2.0
**Updated**: 2026-07-03
