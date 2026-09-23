# Claude Code Lifecycle Hooks — Research Findings

**Research date**: 2026-08-06
**Source**: Official Claude Code documentation at code.claude.com/docs/en/hooks (current)
**Confidence**: High — sourced directly from the live official docs. The event catalog is significantly larger than previously documented in AGENTIC-PATTERNS.md.

---

## 1. Complete Hook Event Catalog

The official docs organize events into four categories.

### Per-Session Events

| Event | When it fires |
|---|---|
| `SessionStart` | Session begins or resumes |
| `Setup` | When run with `--init-only`, `--init`, or `--maintenance` in `-p` mode |
| `SessionEnd` | Session terminates |

### Per-Turn Events

| Event | When it fires |
|---|---|
| `UserPromptSubmit` | Prompt submitted, before Claude processes it |
| `UserPromptExpansion` | User-typed slash command expands into a prompt |
| `Stop` | Claude finishes responding |
| `StopFailure` | Turn ends due to an API error |

### Agentic Loop Events (fires on every tool call except `EndConversation`)

| Event | When it fires |
|---|---|
| `PreToolUse` | Before a tool call executes (can block) |
| `PermissionRequest` | Tool call needs a permission decision |
| `PermissionDenied` | Tool call denied by the auto mode classifier |
| `PostToolUse` | After a tool call succeeds |
| `PostToolUseFailure` | After a tool call fails |
| `PostToolBatch` | After a full batch of parallel tool calls resolves |
| `SubagentStart` | A subagent is spawned |
| `SubagentStop` | A subagent finishes |
| `TaskCreated` | A task is being created via `TaskCreate` |
| `TaskCompleted` | A task is being marked completed |

### Async / Standalone Events

| Event | When it fires |
|---|---|
| `Notification` | Claude Code sends a notification |
| `MessageDisplay` | Assistant message text is displayed |
| `TeammateIdle` | An agent team teammate is about to go idle |
| `InstructionsLoaded` | A CLAUDE.md or rules file is loaded |
| `ConfigChange` | A config file changes during the session |
| `CwdChanged` | Working directory changes |
| `DirectoryAdded` | A working directory is added mid-session |
| `FileChanged` | A watched file changes on disk |
| `WorktreeCreate` | A worktree is being created |
| `WorktreeRemove` | A worktree is being removed |
| `PreCompact` | Before context compaction runs |
| `PostCompact` | After context compaction completes |
| `Elicitation` | An MCP server requests user input |
| `ElicitationResult` | User responds to an MCP elicitation |

**Note for AGENTIC-PATTERNS.md update**: The existing documentation there lists only 8 events (`PreToolUse`, `PostToolUse`, `Stop`, `SubagentStop`, `UserPromptSubmit`, `SessionStart`, `SessionEnd`, `Notification`). The actual catalog is 30+ events. The 8 listed are still accurate but incomplete.

---

## 2. What Each Hook Receives as Input

Every hook receives JSON via **stdin**. Common fields present in every event:

```json
{
  "session_id": "abc123",
  "prompt_id": "550e8400-e29b-41d4-a716-446655440000",
  "transcript_path": "/home/user/.claude/projects/.../transcript.jsonl",
  "cwd": "/home/user/my-project",
  "permission_mode": "default",
  "hook_event_name": "PreToolUse",
  "effort": { "level": "medium" }
}
```

When the hook fires inside a subagent, two additional fields appear:
```json
{
  "agent_id": "...",
  "agent_type": "Explore"
}
```

For `PreToolUse` and `PostToolUse`, the tool-specific fields are added:
```json
{
  "tool_name": "Bash",
  "tool_input": {
    "command": "npm test",
    "description": "Run test suite",
    "timeout": 120000,
    "run_in_background": false
  },
  "tool_use_id": "toolu_01ABC123..."
}
```

**Environment variables**: No special hook-specific env vars are injected beyond what is already in the shell environment. Path placeholders (`${CLAUDE_PROJECT_DIR}`, `${CLAUDE_PLUGIN_ROOT}`, `${CLAUDE_PLUGIN_DATA}`) are resolved in the hook configuration itself (in settings.json), not as env vars inside the script.

**No arguments**: Hook scripts receive everything through stdin JSON. The `args` field in settings.json is for exec-form spawning (bypasses shell), not for passing data to the script.

---

## 3. Exit Code Behavior

This is the most critical operational detail. The behavior is counter-intuitive.

| Exit code | Effect |
|---|---|
| `0` | Success — stdout is parsed for JSON output; event proceeds normally |
| `2` | **Blocking error** — stderr is fed to Claude as an error message; blocks the action |
| Any other (including `1`) | **Non-blocking error** — event proceeds; transcript shows a "hook error" notice with the first line of stderr |

**The key gotcha**: `exit 1` does NOT block. Only `exit 2` blocks. This is intentional but counter-intuitive for anyone coming from standard Unix conventions.

**Second key constraint**: JSON output is only processed on exit 0. If you exit 2, all stdout JSON is ignored. You cannot do structured blocking — you must choose: exit 2 with a stderr message, or exit 0 with JSON `decision: "block"`.

### Which events can actually be blocked by exit 2

| Event | Blocks? | What happens |
|---|---|---|
| `PreToolUse` | Yes | Blocks the tool call |
| `PermissionRequest` | Yes | Denies permission |
| `UserPromptSubmit` | Yes | Blocks the prompt and erases it |
| `UserPromptExpansion` | Yes | Blocks the expansion |
| `Stop` | Yes | Prevents stopping; conversation continues |
| `SubagentStop` | Yes | Prevents subagent from stopping |
| `TeammateIdle` | Yes | Prevents going idle |
| `TaskCreated` | Yes | Rolls back task creation |
| `TaskCompleted` | Yes | Prevents completion marking |
| `ConfigChange` | Yes | Blocks the config change |
| `PostToolBatch` | Yes | Stops agentic loop before next model call |
| `PreCompact` | Yes | Blocks compaction |
| `Elicitation` | Yes | Denies elicitation |
| `ElicitationResult` | Yes | Blocks the response |
| `WorktreeCreate` | Yes (any non-zero) | Fails worktree creation — unique: ANY non-zero exit fails, not just 2 |
| `PostToolUse` | No | Shows stderr to Claude (tool already ran) |
| `PostToolUseFailure` | No | Shows stderr to Claude |
| `StopFailure` | No | Output and exit code ignored entirely |
| `SessionStart`, `Setup`, `SubagentStart` | No | Shows error in transcript; session proceeds |
| `Notification`, `FileChanged`, `PostCompact`, etc. | No | Shows stderr to user only |

---

## 4. Settings.json Configuration Format

### Structure

Three levels of nesting: event name → matcher group → handlers array.

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "/path/to/script.sh",
            "args": [],
            "timeout": 60
          }
        ]
      }
    ]
  }
}
```

### Matcher Syntax

| Matcher value | How it's evaluated |
|---|---|
| `"*"`, `""`, or omitted | Match all |
| Only letters, digits, `_`, `-`, spaces, `,`, `\|` | Exact string or pipe/comma-separated list |
| Any other character | JavaScript RegExp (unanchored) |

```json
"matcher": "Bash"              // exact match
"matcher": "Edit|Write"        // either tool (pipe-separated)
"matcher": "Edit, Write"       // same (v2.1.191+)
"matcher": "mcp__memory__.*"   // all tools from the memory MCP server
"matcher": "^Notebook"         // regex: starts with Notebook
"matcher": "*"                 // match everything
```

**Gotcha — regex matchers are unanchored**: `Edit.*` matches `NotebookEdit`. Use `^Edit$` for an exact single-tool match when using regex syntax.

### What each event type matches on

| Event | Matches on |
|---|---|
| `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `PermissionDenied` | Tool name |
| `SessionStart` | Startup type: `startup`, `resume`, `clear`, `compact`, `fork` |
| `SessionEnd` | Exit type: `clear`, `resume`, `logout`, `prompt_input_exit`, etc. |
| `Notification` | Notification type |
| `SubagentStart` / `SubagentStop` | Agent type |
| `FileChanged` | Literal filenames to watch |
| `StopFailure` | Error type: `rate_limit`, `overloaded`, etc. |
| `UserPromptExpansion` | Command name |
| `Elicitation` / `ElicitationResult` | MCP server name |
| `UserPromptSubmit`, `Stop`, `PostToolBatch`, etc. | No matcher support — always fires |

### MCP Tool Naming Convention

```
mcp__<server>__<tool>

Examples:
  mcp__memory__create_entities
  mcp__filesystem__read_file

Matcher patterns:
  mcp__memory__.*          // all tools from the memory server
  mcp__brave-search__.*    // hyphenated server name
  mcp__.*__write.*         // any write tool from any server
```

### Hook Handler Types and Fields

**Common fields (all handler types)**:

| Field | Required | Description |
|---|---|---|
| `type` | Yes | `"command"`, `"http"`, `"mcp_tool"`, `"prompt"`, `"agent"` |
| `if` | No | Permission-rule-syntax filter, e.g. `"Bash(git *)"`, `"Edit(*.ts)"` |
| `timeout` | No | Seconds before cancel. Default: 600 for command/http/mcp_tool; 30 for prompt; 60 for agent |
| `statusMessage` | No | Custom spinner message shown while hook runs |
| `once` | No | Run once per session then remove (skills only) |

**Command hook fields**:

| Field | Required | Description |
|---|---|---|
| `command` | Yes | Shell command string or executable path |
| `args` | No | Argument list — triggers exec form (no shell, no quoting issues) |
| `async` | No | `true` = fire-and-forget, does not block |
| `asyncRewake` | No | `true` = background execution, wakes Claude when script exits with code 2 |
| `shell` | No | `"bash"` or `"powershell"` |

**Shell form vs exec form**:
- **Shell form** (no `args`): command is passed to `sh -c`; supports pipes, `&&`, redirects
- **Exec form** (with `args`): direct process spawn, no shell; avoids quoting/escaping issues, preferred when using path placeholders

```json
// Shell form — supports pipes
{ "type": "command", "command": "cat | jq '.tool_name'" }

// Exec form — safer for paths
{ "type": "command", "command": "node", "args": ["${CLAUDE_PROJECT_DIR}/.claude/hooks/check.js"] }
```

**HTTP hook fields**:
```json
{
  "type": "http",
  "url": "http://localhost:8080/hooks/pre-tool-use",
  "timeout": 30,
  "headers": { "Authorization": "Bearer $MY_TOKEN" },
  "allowedEnvVars": ["MY_TOKEN"]
}
```

**MCP tool hook fields**:
```json
{
  "type": "mcp_tool",
  "server": "my_server",
  "tool": "security_scan",
  "input": { "file_path": "${tool_input.file_path}" }
}
```

### Settings File Locations and Scope

| File | Scope | Committed to repo? |
|---|---|---|
| `~/.claude/settings.json` | All projects on this machine | No |
| `.claude/settings.json` | This project only | Yes |
| `.claude/settings.local.json` | This project, this machine | No (gitignored) |
| Plugin `hooks/hooks.json` | When plugin is enabled | Yes |
| Skill/agent frontmatter | While that skill/agent is active | Yes |

Hooks from all settings files **merge** — they do not replace each other. All matching hooks for an event run in parallel; order is not guaranteed.

### Skill Frontmatter Hooks (for scoped, temporary hooks)

```yaml
---
name: secure-operations
description: Perform operations with security checks
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/security-check.sh"
---
```

The `once: true` field on a handler removes it after first execution — useful for one-time session setup steps.

### Path Placeholders

| Placeholder | Resolves to |
|---|---|
| `${CLAUDE_PROJECT_DIR}` | Project root directory |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin installation directory |
| `${CLAUDE_PLUGIN_DATA}` | Plugin persistent data directory |

Wrap in double quotes in shell form. Use exec form (`args`) to avoid quoting issues entirely.

---

## 5. JSON Output (exit 0 Structured Control)

When a hook exits 0, Claude Code parses stdout as JSON. This enables structured decisions rather than error-message-based blocking.

### Universal fields (any event)
```json
{
  "continue": false,           // stop Claude entirely
  "stopReason": "Build failed", // shown to user (not to Claude)
  "suppressOutput": true,       // hide stdout from transcript
  "systemMessage": "Warning",   // warning shown to user
  "terminalSequence": "\033]..." // emit terminal escape sequences
}
```

### additionalContext — inject into Claude's context window

The `additionalContext` field injects text into Claude's context as a system reminder. Available in `hookSpecificOutput` for most events.

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": "This file is generated. Edit src/schema.ts and run bun generate instead."
  }
}
```

Where it appears depending on event:
- `SessionStart`/`Setup`/`SubagentStart` → before the first prompt
- `UserPromptSubmit`/`UserPromptExpansion` → alongside the prompt
- `PreToolUse`/`PostToolUse`/`PostToolBatch` → next to the tool result
- `Stop`/`SubagentStop` → end of turn (conversation continues)

Limit: 10,000 characters. Excess is saved to a temp file; Claude gets a preview and the path.

### Event-specific output structures

**PreToolUse** — can rewrite tool arguments or make permission decisions:
```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Blocked by policy",
    "updatedInput": { "command": "echo safe" }
  }
}
```

**PostToolUse** — can replace tool output Claude sees:
```json
{
  "decision": "block",
  "reason": "Output validation failed",
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "updatedToolOutput": "sanitized output",
    "additionalContext": "Note: generated file"
  }
}
```

**Stop / SubagentStop** — can prevent stopping:
```json
{
  "decision": "block",
  "reason": "Tests still failing, keep going"
}
```

**Stop with feedback** — prevents stopping and injects context:
```json
{
  "hookSpecificOutput": {
    "hookEventName": "Stop",
    "additionalContext": "Remember to update CHANGELOG.md"
  }
}
```

**SessionStart** — richest output options:
```json
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "...",
    "initialUserMessage": "Start with: git status",
    "watchPaths": ["/path/to/watch"],
    "sessionTitle": "My Session",
    "reloadSkills": true
  }
}
```

---

## 6. High-Impact Patterns for Consulting and Agile Workflow Toolkits

### Tier 1 — Highest Impact (implement in every toolkit)

**A. Session close auto-update (Stop hook)**

The most valuable hook for consulting toolkits. Forces ACTION-ITEMS.md, APP-CONTEXT.md, or equivalent living docs to be updated before every session close.

```bash
#!/bin/bash
# .claude/hooks/session-close-check.sh
input=$(cat)
# Check if key docs were updated this session; if not, inject reminder
jq -n '{
  hookSpecificOutput: {
    hookEventName: "Stop",
    additionalContext: "Before closing: confirm ACTION-ITEMS.md reflects current state, and any new codebase areas are captured in APP-CONTEXT.md."
  }
}'
```

```json
{
  "hooks": {
    "Stop": [{
      "hooks": [{
        "type": "command",
        "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/session-close-check.sh"
      }]
    }]
  }
}
```

**B. Session warm-start context injection (SessionStart hook)**

Automatically loads engagement context at every session start, eliminating the need to manually run `/brief` or describe the project.

```json
{
  "hooks": {
    "SessionStart": [{
      "matcher": "startup",
      "hooks": [{
        "type": "command",
        "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/session-start.sh"
      }]
    }]
  }
}
```

```bash
#!/bin/bash
# .claude/hooks/session-start.sh
PROJECT_DIR="${CLAUDE_PROJECT_DIR}"
context=""
for f in "$PROJECT_DIR/docs/PROJECT-CONTEXT.md" "$PROJECT_DIR/docs/ACTION-ITEMS.md"; do
  [ -f "$f" ] && context="$context\n\n$(cat "$f")"
done
jq -n --arg ctx "$context" '{
  hookSpecificOutput: {
    hookEventName: "SessionStart",
    additionalContext: $ctx
  }
}'
```

**C. Dangerous command guard (PreToolUse hook)**

Blocks destructive shell commands before they execute. Essential for consulting engagements where Claude has broad permissions.

```json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "Bash",
      "hooks": [{
        "type": "command",
        "if": "Bash(rm *)",
        "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/guard-rm.sh",
        "args": []
      }]
    }]
  }
}
```

```bash
#!/bin/bash
# .claude/hooks/guard-rm.sh
COMMAND=$(cat | jq -r '.tool_input.command')
if echo "$COMMAND" | grep -qE 'rm\s+-rf\s+/|rm\s+-rf\s+~'; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "Destructive root/home delete blocked by toolkit hook"
    }
  }'
else
  exit 0
fi
```

### Tier 2 — High Impact for Code Toolkits

**D. Auto-format after file edits (PostToolUse hook)**

Ensures consistent formatting after every Claude file write without requiring the user to remember to run a formatter.

```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Edit|Write",
      "hooks": [{
        "type": "command",
        "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/format.sh",
        "async": true
      }]
    }]
  }
}
```

**E. Test runner after file writes (PostToolUse hook)**

Runs the relevant test suite after any file write and injects results into Claude's context. This closes the loop on TDD workflows automatically.

```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Edit|Write",
      "hooks": [{
        "type": "command",
        "if": "Edit(src/**/*.ts)",
        "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/run-tests.sh"
      }]
    }]
  }
}
```

**F. Block Stop when tests are failing (Stop hook)**

Prevents Claude from completing a turn while tests are red. Forces it to stay in the loop until green.

```bash
#!/bin/bash
if npm test 2>&1 | grep -q "FAIL\|failing"; then
  echo "Tests are still failing. Fix them before stopping." >&2
  exit 2
fi
```

### Tier 3 — Useful for Specific Scenarios

**G. Desktop notification on session idle (Notification hook)**

Tells the user when Claude is waiting for input. Useful in long-running async work.

```bash
#!/bin/bash
input=$(cat)
body=$(echo "$input" | jq -r '.message // "Needs your attention"')
seq=$(printf '\033]777;notify;Claude Code;%s\007' "$body")
jq -nc --arg seq "$seq" '{terminalSequence: $seq}'
```

**H. Watch .env file for changes (FileChanged hook)**

Reloads environment configuration when `.env` changes during a session.

```json
{
  "hooks": {
    "FileChanged": [{
      "matcher": ".env",
      "hooks": [{
        "type": "command",
        "command": "direnv allow && direnv reload",
        "async": true
      }]
    }]
  }
}
```

**I. Async background logging (any event)**

Fire-and-forget logging of all tool activity. Does not block execution. Useful for auditing on client engagements.

```json
{
  "type": "command",
  "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/log-activity.sh",
  "async": true
}
```

**J. asyncRewake pattern for long-running background tasks**

Starts a background job (build, test suite) and wakes Claude when it finishes with a failure. Claude is interrupted only when action is needed.

```json
{
  "type": "command",
  "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/build-monitor.sh",
  "asyncRewake": true
}
```

---

## 7. Gotchas, Limitations, and Failure Modes

1. **exit 1 is not blocking** — only exit 2 blocks. This trips up anyone applying standard Unix conventions. The intent is that unexpected errors (exit 1) are non-fatal; only deliberate policy blocks (exit 2) stop execution.

2. **JSON and exit codes are mutually exclusive** — structured JSON output is only processed on exit 0. If you exit 2, all stdout is ignored. Choose one mode per hook: error-message-based blocking (exit 2 + stderr), or structured control (exit 0 + JSON).

3. **No `/dev/tty` access** — as of v2.1.139, hooks run without a controlling terminal. You cannot write interactive UI or notifications directly. Use `terminalSequence` in JSON output instead.

4. **Stdout must be pure JSON** — shell profile startup text (from `.bashrc`, `.zshrc`, etc.) will break JSON parsing. If hooks behave inconsistently, check for profile output.

5. **All matching hooks run in parallel** — if multiple hook handlers match an event, order of execution is not guaranteed.

6. **`if` field fails open** — the `if` field (permission rule filter) fails open on ambiguous or unparseable Bash commands. If Claude writes a complex shell expression, the `if` filter may not be able to evaluate it and will run the hook anyway. Do not use `if` as a hard security enforcement mechanism.

7. **Transcript lag** — `transcript_path` may not include messages from the current turn. For `Stop` hooks that need to see the last response, use the `last_assistant_message` field (available on Stop events) rather than reading the transcript file.

8. **MCP hooks on SessionStart** — MCP servers may not be connected yet when `SessionStart` fires. Don't use `mcp_tool` type hooks on `SessionStart`.

9. **UserPromptSubmit default timeout is 30s** — lower than the 600s default for other events. Keep these hooks fast.

10. **SessionEnd budget** — all `SessionEnd` hooks share a 1.5-second budget (extendable to 60s with an explicit `timeout` setting). Long-running teardown in `SessionEnd` will be killed.

11. **WorktreeCreate exits differently** — any non-zero exit (not just exit 2) fails worktree creation. This is unique among all hook events.

12. **Regex matchers are unanchored** — `Edit.*` matches `NotebookEdit`. Use `^Edit$` for exact-match regex.

13. **Hyphenated exact matchers require v2.1.195+** — on earlier versions, a matcher like `code-reviewer` is treated as a regex, not an exact string.

14. **Cloud sessions** — cloud-hosted sessions do not read `~/.claude/settings.json`. Hooks must come from the repo's `.claude/settings.json` or organization managed settings.

15. **`disableAllHooks`** — organization-managed hooks cannot be disabled by project or user settings unless set at the managed policy level.

16. **Hook merge, not replace** — hooks from all settings files are merged, not replaced. A user-level hook and a project-level hook for the same event both fire. There is no way to suppress a higher-scope hook from a lower-scope file (unless using `allowManagedHooksOnly`).

17. **additionalContext cap** — 10,000 characters per hook. Larger outputs are saved to a temp file; Claude sees a preview and the path.

18. **Path placeholders in shell form** — wrap `${CLAUDE_PROJECT_DIR}` in double quotes. Prefer exec form (with `args`) when paths may contain spaces.

---

## 8. What Needs Updating in AGENTIC-PATTERNS.md

The current AGENTIC-PATTERNS.md (`.meta/AGENTIC-PATTERNS.md`, lines 170-183) lists only 8 hook events and is otherwise accurate. Required updates:

1. **Replace the 8-event list** with a reference to the four categories (Per-Session, Per-Turn, Agentic Loop, Async/Standalone) and the full count (~30 events)
2. **Expand "Use hooks for" section** with the Tier 1/2/3 pattern breakdown from this research
3. **Clarify exit code behavior** — the current text ("use exit 2 not exit 1") is correct but incomplete; add the JSON-vs-exit-code constraint
4. **Add consulting-specific hook patterns** (Stop for doc updates, SessionStart for warm context) which are not currently mentioned

---

## 9. Recommended Default Hook Configuration for Generated Toolkits

Based on this research, the recommended baseline for a consulting/agile toolkit is three hooks:

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
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/session-close-check.sh",
            "args": [],
            "timeout": 10
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
            "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/guard-rm.sh",
            "args": []
          }
        ]
      }
    ]
  }
}
```

For code toolkits, add a `PostToolUse` handler on `Edit|Write` for the formatter and optionally the test runner.

---

## Sources

- Primary: https://code.claude.com/docs/en/hooks (official, current as of 2026-08-06)
- Secondary: https://code.claude.com/docs/en/settings (hook-related settings fields)
- Context: `.meta/AGENTIC-PATTERNS.md` (existing project documentation for gap analysis)
- Context: `TODO.md` item G1 (the research question that prompted this session)
