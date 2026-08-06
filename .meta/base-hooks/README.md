# Base Hooks — Claude Code Lifecycle Hook Templates

This directory contains everything needed to add lifecycle hooks to a generated toolkit. Hooks are **not currently wired into the generator** — they are ready to be enabled when the time is right.

---

## Current Status

**Not in use.** The generator does not ask about hooks during Phase 4 and does not generate hook files during Phase 7. This directory is a complete, tested foundation for when that changes.

**Why not yet**: Hook reliability depends on clean session ends. In environments where OAuth token expiry causes abrupt session termination (Ctrl+C + re-auth + `claude --continue`), the `Stop` hook — the most valuable for consulting toolkits — fires inconsistently. The `/add-checkpoint` base skill covers the same ground manually in the interim.

**When to enable**: When session stability allows reliable clean shutdowns. See "Generator Wiring" section below for the exact PHASES.md changes needed.

---

## What Hooks Are

Claude Code lifecycle hooks are shell scripts (or HTTP endpoints, or MCP tools) that fire automatically at specific moments in a Claude Code session. They are **additive** — they add behavior on top of Claude's normal operation without replacing anything. There are no "built-in hooks" to override.

Hooks are configured in `settings.json` under a `"hooks"` key. They fire based on the event type and an optional matcher (tool name, session type, file pattern, etc.).

**The single most important thing to know**: `exit 1` does NOT block. Only `exit 2` blocks. This trips everyone coming from standard Unix conventions.

---

## Contents

```
.meta/base-hooks/
  README.md                 — this file
  HOOKS-REFERENCE.md        — all 30 hook events, organized by category
  settings.hooks.json       — ready-to-merge settings layer (3 Tier 1 hooks)
  scripts/
    session-start.sh        — ★ SessionStart: warm-start context injection
    session-close-check.sh  — ★ Stop: doc-update reminder on session close
    guard-destructive.sh    — ★ PreToolUse: block dangerous rm/force-push
    notify.sh               — Notification: desktop alert when Claude goes idle
```

The ★ scripts are the Tier 1 baseline — configure these three and you have the highest-value hook setup for any consulting or agile toolkit.

---

## How It Works in a Generated Toolkit

When hooks are enabled, the generated toolkit gets:

```
.claude/
  settings.json         ← hooks block added (merged from settings.hooks.json)
  hooks/
    session-start.sh
    session-close-check.sh
    guard-destructive.sh
    [optional additional scripts]
```

All scripts in `.claude/hooks/` need to be `chmod +x` after generation. The generator will do this automatically when hooks are wired in.

---

## Disable / Re-Enable

**Disable all hooks** (without removing them): add to `.claude/settings.local.json`:
```json
{ "disableAllHooks": true }
```
Claude Code picks this up live — no restart needed. Remove to re-enable.

**Disable a specific hook** by script check (build this into any script you want to be togglable):
```bash
if [ "${CLAUDE_HOOKS_DISABLED:-}" = "1" ] || [ -f "${CLAUDE_PROJECT_DIR}/.hooks-paused" ]; then
  exit 0  # silent no-op
fi
```

Set `CLAUDE_HOOKS_DISABLED=1` in your environment, or `touch .hooks-paused` in the project root to pause without changing any code.

---

## Prerequisites

- `jq` must be on PATH — all scripts depend on it. Check: `which jq`. Install via Homebrew: `brew install jq`.
- All scripts must be executable: `chmod +x .claude/hooks/*.sh`
- Do not let `.bashrc` or `.zshrc` print anything to stdout — it corrupts JSON parsing. Add `[[ $- == *i* ]] || return` before any output in shell profiles.

---

## Generator Wiring

**When ready to enable hooks in the generator, make these changes:**

### PHASES.md — Phase 4 addition

Add after the path-scoped rules question, for code toolkits and any multi-session toolkit:

```
"Do you want automatic lifecycle hooks in this toolkit?
  Hooks fire automatically at specific moments — no manual invocation needed.

  Tier 1 (recommended for any toolkit):
  1. Session context load (SessionStart) — loads PROJECT-CONTEXT.md and ACTION-ITEMS.md at session start
  2. Doc-update reminder (Stop) — prompts to update reference files before session closes
  3. Destructive command guard (PreToolUse) — blocks rm -rf targeting root/home directories

  Code toolkit additions (PostToolUse):
  4. Auto-formatter — run prettier/black/gofmt after every file write
  5. Test runner — run relevant tests after file writes and inject results

  Options:
  1. Yes — include Tier 1 baseline (recommended)
  2. Yes — include Tier 1 + code additions (code toolkits only)
  3. No — skip hooks for now (can be added later)
  4. Not sure yet — defer as stub"
```

### PHASES.md — Phase 7 addition

Add to the conditional generation list:

```
[N]. .claude/hooks/ — if hooks confirmed in Phase 4:
    - Copy confirmed scripts from .meta/base-hooks/scripts/ to .claude/hooks/
    - Run chmod +x on all copied scripts
    - Merge .meta/base-hooks/settings.hooks.json into .claude/settings.json
    - Add to GETTING_STARTED.md: "Hooks are active. To disable: add disableAllHooks: true to .claude/settings.local.json"
```

### PHASES.md — Phase 6 confirmation summary addition

Add to the ADVANCED section in PROMPTS.md:
```
  Hooks: [Tier 1 / Tier 1 + code / "Not enabled"]
```

---

## Relationship to /add-checkpoint

`/add-checkpoint` is the manual skill that covers the same ground as the `Stop` hook. They are alternatives, not duplicates:

| | `/add-checkpoint` | `Stop` hook |
|---|---|---|
| Invocation | Manual — you run it when you choose | Automatic — fires at every session end |
| Reliability | Always works | Depends on clean session close |
| Control | You decide when to checkpoint | Fires every time, no exceptions |
| Best for | Environments with unstable sessions | Environments with reliable clean shutdowns |

Use `/add-checkpoint` now. Enable the `Stop` hook when your environment supports it.

---

## See Also

- `HOOKS-REFERENCE.md` in this directory — full catalog of all 30 hook events
- `research/hooks.md` and `research/hooks-practical.md` — sourced research (not committed to repo)
- `.meta/AGENTIC-PATTERNS.md` — hook patterns section (currently lists 8 events; update when wiring in)
- `.meta/CLAUDE-CODE-SKILLS-REFERENCE.md` — skill frontmatter hooks support
