# Claude Code Hooks — Practical Reference

**Research date**: 2026-08-06
**Builds on**: `research/hooks.md` (event catalog, exit codes, settings structure)
**Sources**: Official docs at code.claude.com/docs/en/hooks (current), all sub-sections fetched directly
**Scope of this file**: Script syntax, community patterns, disable/re-enable, debugging, performance — the things you need to actually write and ship hooks

---

## 1. Canonical Bash Script Structure

Every hook script follows the same skeleton:

```bash
#!/bin/bash
# Read stdin ONCE — hooks only get one pass
input=$(cat)

# Extract fields with jq
tool_name=$(jq -r '.tool_name' <<<"$input")
command=$(jq -r '.tool_input.command // empty' <<<"$input")
file_path=$(jq -r '.tool_input.file_path // empty' <<<"$input")
session_id=$(jq -r '.session_id' <<<"$input")
cwd=$(jq -r '.cwd' <<<"$input")

# --- your logic here ---

# Exit paths:
# exit 0            → pass-through (no opinion)
# exit 0 + JSON     → structured decision (allow/deny/context injection)
# exit 2 + stderr   → blocking error message shown to Claude
# exit 1            → NON-blocking (action proceeds with a logged notice)
```

**Critical**: `input=$(cat)` must come before any other command that reads stdin. Do it once; pipe `$input` thereafter using `<<<"$input"`.

**Critical**: `jq` must be on `PATH`. All hooks that parse JSON depend on it. If hooks behave erratically, check: `which jq`.

---

## 2. The Four Script Modes — When to Use Each

| Mode | How | When |
|---|---|---|
| Silent pass-through | `exit 0` (no stdout) | Hook has no opinion on this call |
| Structured allow/deny | `exit 0` + JSON to stdout | Programmatic decision; Claude sees reason |
| Blocking error | `exit 2` + message to stderr | Hard block; error shown to Claude as tool failure |
| Non-blocking notice | `exit 1` (any other code) | Log/audit only; DO NOT use to block |

**The gotcha everyone hits**: `exit 1` does not block. Only `exit 2` blocks. Exit 0 + JSON `decision: "block"` also blocks but requires proper JSON output.

---

## 3. Top Practical Hook Scripts

### Hook 1: Stop hook — doc-update reminder (highest consulting value)

This is the single most useful hook for consulting/agile toolkits. It injects a reminder into Claude's context at the end of every turn, prompting doc maintenance before the session closes.

**`session-close-check.sh`**:
```bash
#!/bin/bash
input=$(cat)

# Inject a non-blocking reminder; conversation continues so Claude can act on it
jq -n '{
  hookSpecificOutput: {
    hookEventName: "Stop",
    additionalContext: "Session closing check: confirm ACTION-ITEMS.md reflects current state. If you added new codebase areas, update APP-CONTEXT.md. If you deferred anything, capture it in ACTION-ITEMS.md under a TODO section."
  }
}'
exit 0
```

**Settings entry**:
```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/session-close-check.sh",
            "args": [],
            "timeout": 10,
            "statusMessage": "Checking session close conditions..."
          }
        ]
      }
    ]
  }
}
```

**How it works**: `additionalContext` on a `Stop` event is inserted as a system reminder at the end of the turn. The conversation continues (Claude reads the reminder on its next model request). This is not an error — it's a non-blocking nudge. Claude will act on it before the user sees the final response.

**Key gotcha**: Do NOT phrase `additionalContext` as imperative commands ("you must update ACTION-ITEMS.md"). Write it as factual statements ("Session closing check: ACTION-ITEMS.md should reflect current state"). Imperative phrasing can trigger Claude's prompt-injection defenses, causing Claude to surface the text to the user instead of treating it as context.

**Confidence**: High. Pattern sourced directly from official docs with exact field names and placement behavior confirmed.

---

### Hook 2: SessionStart hook — warm-start context injection (eliminates /brief)

Loads engagement context at every session start so the user never has to manually describe the project.

**`session-start.sh`**:
```bash
#!/bin/bash
PROJECT_DIR="${CLAUDE_PROJECT_DIR}"
context=""

# Load whatever context docs exist — fail gracefully if any are missing
for f in \
  "$PROJECT_DIR/docs/PROJECT-CONTEXT.md" \
  "$PROJECT_DIR/docs/ACTION-ITEMS.md"; do
  if [ -f "$f" ]; then
    context="$context

---

$(cat "$f")"
  fi
done

# Only inject if there's something to say
if [ -n "$context" ]; then
  jq -n --arg ctx "$context" '{
    hookSpecificOutput: {
      hookEventName: "SessionStart",
      additionalContext: $ctx
    }
  }'
else
  exit 0
fi
```

**Settings entry**:
```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/session-start.sh",
            "args": [],
            "timeout": 30,
            "statusMessage": "Loading engagement context..."
          }
        ]
      }
    ]
  }
}
```

**Matcher note**: `"startup"` fires only on fresh session starts, not `resume`, `clear`, `compact`, or `fork`. To also refresh context on resume, use `"startup|resume"` or omit the matcher entirely.

**Resume behavior**: On `--resume` (continuing a previous session), the `SessionStart` hook re-runs with `source: "resume"` — so dynamic values like branch name and CI status are refreshed. However, `additionalContext` from a previous `Stop` hook is replayed from transcript, not re-run. Static docs (PROJECT-CONTEXT.md) loaded here are always fresh.

**Context limit**: 10,000 characters per hook. If your combined docs exceed this, they're written to a temp file and Claude gets a path + preview instead of inline text. Keep the combined context focused.

**Confidence**: High. Field names, matcher values, and placement behavior confirmed from official docs.

---

### Hook 3: PreToolUse guard — block destructive rm commands

**`guard-destructive.sh`**:
```bash
#!/bin/bash
input=$(cat)
command=$(jq -r '.tool_input.command // empty' <<<"$input")

# Block rm -rf targeting root, home, or project root
if echo "$command" | grep -qE 'rm\s+-rf\s+(/|~|/home|/Users)'; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "Blocked: rm -rf targeting root/home directories is not allowed by toolkit policy"
    }
  }'
  exit 0
fi

# Also block git push --force to main/master without explicit confirmation
if echo "$command" | grep -qE 'git push.*--force.*(main|master)|git push.*-f.*(main|master)'; then
  echo "Force push to main/master blocked by toolkit policy" >&2
  exit 2
fi

exit 0
```

**Settings entry**:
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "if": "Bash(rm *)",
            "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/guard-destructive.sh",
            "args": []
          }
        ]
      }
    ]
  }
}
```

**Two block modes shown above**:
- `exit 0` + JSON `permissionDecision: "deny"` → structured denial; Claude sees the reason as a permission decision
- `exit 2` + stderr → error-style blocking; stderr shown to Claude as an error message

The structured JSON mode (exit 0) is cleaner for permission flows. The exit 2 mode is simpler to write. Both block. Choose based on how you want it to appear in the transcript.

**`if` field note**: The `if: "Bash(rm *)"` pre-filter prevents the hook process from even spawning when the command doesn't start with `rm`. This is a performance optimization — use it for high-frequency tools like Bash. However: `if` fails open on complex/unparseable commands. Do not rely on `if` alone as a security boundary; put your actual pattern matching logic inside the script.

**Confidence**: High for basic patterns. Moderate for the regex precision — test with `echo '{...}' | bash script.sh` before relying on it.

---

### Hook 4: Desktop notification on session idle (Notification hook)

```bash
#!/bin/bash
input=$(cat)
body=$(jq -r '.message // "Claude is waiting for your input"' <<<"$input")

# macOS/Linux terminal notification via escape sequence
seq=$(printf '\033]777;notify;Claude Code;%s\007' "$body")
jq -nc --arg seq "$seq" '{terminalSequence: $seq}'
```

**Settings entry**:
```json
{
  "hooks": {
    "Notification": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/notify.sh",
            "async": true
          }
        ]
      }
    ]
  }
}
```

**`async: true`** means this fires without blocking — critical for notifications. The terminal escape sequence approach (`\033]777;notify`) works in terminals that support it (iTerm2, many others). For macOS system notifications, replace the `seq` approach with `osascript -e 'display notification "..." with title "Claude Code"'` — but that requires subprocess spawn, slower.

**Confidence**: High for the `async: true` and JSON output pattern. Moderate for terminal sequence support — depends on the terminal emulator.

---

## 4. Disable / Re-Enable Patterns

### Disable all hooks temporarily

Add to `~/.claude/settings.json` or `.claude/settings.local.json`:

```json
{
  "disableAllHooks": true
}
```

File watcher picks up changes without restarting Claude Code. Remove the field (or set to `false`) to re-enable. This does NOT disable managed (org-level) hooks.

### Per-hook disable — no built-in mechanism

The official docs explicitly state: "There is no way to disable an individual hook while keeping it in the configuration."

To disable a specific hook, delete its entry from the settings JSON. To do this non-destructively, move the entry to a commented-out section — but note JSON does not support comments, so the cleanest approach is a separate `hooks-disabled.json` file you move entries to/from.

### Implement your own per-hook disable via env var check

Build this into hook scripts you want to be togglable:

```bash
#!/bin/bash
# Check for disable flag before doing anything
if [ "${CLAUDE_HOOKS_DISABLED:-}" = "1" ] || [ -f "${CLAUDE_PROJECT_DIR}/.hooks-paused" ]; then
  exit 0  # silent no-op
fi

input=$(cat)
# ... rest of hook logic
```

Set `CLAUDE_HOOKS_DISABLED=1` in your environment to pause all hooks that have this guard. The flag-file variant (`.hooks-paused`) is useful when you want to pause hooks from within a hook script itself.

### Scope control: use settings.local.json for machine-specific hooks

Put machine-specific or developer-specific hooks in `.claude/settings.local.json` (gitignored). This keeps them out of the repo while still firing locally. To disable only local hooks while keeping project hooks active, delete or empty `settings.local.json`.

---

## 5. Debugging When a Hook Fails Silently

Silent failure is the hardest part of hooks. Here are the causes and how to find them.

### Step 1: Use the /hooks menu

Type `/hooks` in Claude Code. It shows every configured hook, its source file, matcher, and full command. If a hook isn't listed, it isn't configured (settings JSON has an error, wrong file location, or wrong event name).

### Step 2: Test the script manually

Since hooks receive JSON on stdin, you can reproduce any hook invocation from the terminal:

```bash
# Test a PreToolUse hook
echo '{
  "session_id": "test",
  "hook_event_name": "PreToolUse",
  "tool_name": "Bash",
  "tool_input": { "command": "rm -rf /tmp/build" },
  "tool_use_id": "toolu_test",
  "cwd": "/tmp/test-project",
  "permission_mode": "default"
}' | bash /path/to/hook-script.sh
echo "Exit: $?"
```

Check:
1. Exit code (`$?`) — 0 means JSON-based control, 2 means blocking stderr, anything else means non-blocking
2. What went to stdout (should be valid JSON or empty)
3. What went to stderr (error messages)

### Step 3: Check for profile interference

```bash
# Run hook with a clean environment to isolate profile output
env -i bash /path/to/hook-script.sh < /dev/null
```

If you get output when you shouldn't, your `.bashrc` or `.zshrc` is printing to stdout, which corrupts JSON parsing.

Fix by adding this at the top of your shell profile's hook-sensitive sections:
```bash
# Only print output in interactive shells
[[ $- == *i* ]] || return
```

### Step 4: Enable debug logging

Run Claude Code with the `--debug` flag to capture full stderr and stdout for all hook executions. This is the only way to see what's happening for exit-0 hooks (where stderr goes to the debug log, not the transcript).

### Step 5: Check the transcript for hook error notices

When a hook exits with any code other than 0 or 2 (e.g., `exit 1`), the transcript shows a `<hook name> hook error` notice with the first line of stderr. This is the primary visible indicator that something went wrong non-fatally.

### Silent failure causes checklist

| Cause | Symptom | Fix |
|---|---|---|
| `exit 1` instead of `exit 2` | Action proceeds; transcript notice | Change to `exit 2` |
| Profile output on stdout | JSON parse error; hook appears to do nothing | Add `-i` check to profile |
| `if` field doesn't match | Hook never fires for that command | Test `if` pattern separately |
| `jq` not on PATH | Bash errors; exit 1 (non-blocking) | `which jq`; install if missing |
| Missing shebang | Script runs with wrong shell | Add `#!/bin/bash` |
| Script not executable | Permission denied; exit 1 | `chmod +x script.sh` |
| MCP hook on `SessionStart` | "not connected" error, non-blocking | Move to `PostToolUse` or use `command` type instead |
| HTTP hook returns non-2xx | Non-blocking error | Return `2xx` with JSON `decision: "block"` to block |
| `disableAllHooks: true` in any settings file | All hooks silently do nothing | Check all settings files |
| Context > 10,000 chars | Claude gets file path + preview instead of inline text | Trim context or split across multiple hooks |

---

## 6. additionalContext in Practice

### How it actually appears to Claude

`additionalContext` is wrapped in a `<system-reminder>` tag injected into the context window. Claude sees it as an instruction-like note, not as a user message. It does not appear in the chat interface.

Placement by event:
- `SessionStart`, `Setup`, `SubagentStart` → before the first prompt
- `UserPromptSubmit`, `UserPromptExpansion` → alongside the prompt
- `PreToolUse`, `PostToolUse`, `PostToolBatch` → next to the tool result
- `Stop`, `SubagentStop` → end of turn (conversation continues)

### Writing text that works

The docs explicitly advise writing factual statements, not commands:

| Works | Does not work reliably |
|---|---|
| `"The deployment target is production"` | `"You must not deploy to production"` |
| `"This repo uses bun test, not npm test"` | `"Always use bun test"` |
| `"Tests are currently failing: auth.test.ts line 42"` | `"Fix the failing tests now"` |
| `"ACTION-ITEMS.md was last updated 3 days ago"` | `"Update ACTION-ITEMS.md before stopping"` |

Imperative framing ("you must", "always", "fix now") can trigger Claude's prompt-injection defenses. Write it as if you're reading from a status board, not giving orders.

### Dynamic context injection pattern

The `PostToolUse` + `additionalContext` pattern is powerful for files that have constraints. After Claude writes/edits a file, inject a warning if it's a generated file:

```bash
#!/bin/bash
input=$(cat)
file=$(jq -r '.tool_input.file_path // empty' <<<"$input")

case "$file" in
  *generated*|*dist/*|*build/*)
    jq -n --arg file "$file" '{
      hookSpecificOutput: {
        hookEventName: "PostToolUse",
        additionalContext: ($file + " is a generated file. Source of truth is src/schema.ts — run `bun generate` to regenerate.")
      }
    }'
    ;;
  *)
    exit 0
    ;;
esac
```

---

## 7. Performance: What to Know

### Sync hooks block the critical path

`PreToolUse` and `Stop` hooks block execution. Every millisecond they take is added to every tool call or turn end. Keep them fast.

| Hook type | Default timeout | In critical path? |
|---|---|---|
| `PreToolUse` | 600s | Yes — blocks tool call |
| `PostToolUse` | 600s | Yes — Claude waits before proceeding |
| `Stop` | 600s | Yes — blocks turn completion |
| `SessionStart` | 600s | Only at session start |
| `UserPromptSubmit` | **30s** | Yes — blocks prompt processing |
| `MessageDisplay` | **10s** | Yes — blocks display |
| `SessionEnd` | 1.5s budget (up to 60s) | End of session only |

**Always set explicit `timeout`** for hooks that might hang:

```json
{
  "type": "command",
  "command": "/path/to/hook.sh",
  "timeout": 5
}
```

### Async for everything that doesn't need to block

Use `async: true` for logging, notifications, background checks:

```json
{
  "type": "command",
  "command": "/path/to/logger.sh",
  "async": true
}
```

Use `asyncRewake: true` for background jobs that should alert Claude on failure (build monitors, test watchers):

```json
{
  "type": "command",
  "command": "/path/to/build-monitor.sh",
  "asyncRewake": true
}
```

`asyncRewake` = fire-and-forget, but if the script exits `2`, Claude is woken and shown the hook's stderr as a system reminder. Use this for CI/build watchers that run while Claude is idle.

### The `if` field avoids unnecessary spawns

```json
"if": "Bash(rm *)"
```

This pre-filter is evaluated before spawning the hook process. If it doesn't match (e.g., the command was `npm test`), the hook never runs. For high-frequency tools like `Bash` with `PreToolUse` hooks, this can save significant overhead. The `if` check is fast — it's a pattern match, not a subprocess.

### Multiple hooks run in parallel

All matching hooks for an event run concurrently. Total latency = slowest hook, not sum. Design multiple hooks to be independent.

---

## 8. Community-Shared Patterns (Commonly Referenced)

Note: GitHub search for public repos with Claude Code hooks is sparse as of this research — the feature is still relatively new and most usage is in private/org repos or dotfiles. The following are the most-cited patterns from the official docs and community discussions.

**Most commonly recommended hooks** (in rough order of community mention):

1. **`rm -rf` guard** (PreToolUse) — universally recommended for any autonomous Claude Code setup
2. **Auto-formatter** (PostToolUse on Edit|Write) — `prettier`, `eslint --fix`, `black`, `gofmt`
3. **Desktop notification** (Notification) — essential for long-running tasks
4. **Linter after edit** (PostToolUse) — feed lint results back to Claude via stderr/additionalContext
5. **Stop-if-tests-failing** (Stop) — keep Claude in the loop until tests are green
6. **Session context injection** (SessionStart) — load project state from docs

**Emerging pattern: prompt-type hooks for semantic validation**

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "prompt",
            "prompt": "Review this bash command for safety issues: $ARGUMENTS\n\nIf the command could cause data loss or system damage, return JSON: {\"decision\": \"block\", \"reason\": \"explanation\"}. If safe, return {\"decision\": \"allow\"}.",
            "timeout": 30
          }
        ]
      }
    ]
  }
}
```

The `prompt` type sends a single-turn query to a Claude model inside the hook system. It's semantic rather than pattern-based. Default timeout is 30s (not 600s like `command`). Use for judgment calls that pattern matching can't handle; use `command` for deterministic checks.

---

## 9. Confidence Ratings on Key Claims

| Claim | Confidence | Source |
|---|---|---|
| `exit 2` blocks, `exit 1` does not | High | Official docs, confirmed |
| `additionalContext` wraps in system-reminder tag | High | Official docs, confirmed |
| Stop hook `additionalContext` continues conversation | High | Official docs, confirmed |
| Factual phrasing works better than imperative | High | Official docs, explicit guidance |
| `disableAllHooks` disables all but managed hooks | High | Official docs, confirmed |
| No built-in per-hook disable mechanism | High | Official docs, explicitly stated |
| `if` field fails open on ambiguous commands | High | Official docs, confirmed |
| Profile output breaks JSON parsing | High | Documented gotcha, confirmed |
| `/hooks` menu is read-only | High | Official docs, confirmed |
| `jq` required (not bundled) | High | All official examples use it with no bundle note |
| `additionalContext` imperative phrasing triggers injection defenses | Moderate-High | Official docs say this explicitly but exact behavior not shown with examples |
| Terminal escape sequence for macOS notify | Moderate | Pattern shown in docs; actual terminal support varies |
| `prompt` hook type uses "fast model" by default | Moderate | Docs say this but don't name the model |
| Community adoption patterns / most common hooks | Moderate | Based on docs examples + indirect community signals; no large-scale survey data available |

---

## 10. Minimal Hook Setup for a Consulting/Agile Toolkit

For a toolkit with `docs/PROJECT-CONTEXT.md` and `docs/ACTION-ITEMS.md`:

**`.claude/settings.json` additions:**

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/session-start.sh",
            "args": [],
            "timeout": 30,
            "statusMessage": "Loading project context..."
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/session-close-check.sh",
            "args": [],
            "timeout": 10,
            "statusMessage": "Checking session close conditions..."
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "if": "Bash(rm *)",
            "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/guard-destructive.sh",
            "args": []
          }
        ]
      }
    ]
  }
}
```

Three scripts required in `.claude/hooks/`:
- `session-start.sh` — loads PROJECT-CONTEXT.md + ACTION-ITEMS.md into context
- `session-close-check.sh` — injects doc-update reminder at turn end
- `guard-destructive.sh` — blocks dangerous rm/force-push commands

All three scripts need `chmod +x`.

---

## Sources

- Primary: https://code.claude.com/docs/en/hooks (all sub-sections, fetched 2026-08-06)
- Prior research: `research/hooks.md` (event catalog, exit codes, settings format)
