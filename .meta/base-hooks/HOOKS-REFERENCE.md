# Claude Code Hooks — Complete Reference

All 30 hook events, organized by category. The four ★ events have full setup and best-practice detail. All others have reference-level entries sufficient to implement them when needed.

**Source**: Official Claude Code documentation, code.claude.com/docs/en/hooks (confirmed 2026-08-06)

---

## How to Read This Document

Each event entry covers:
- **When it fires** — the exact trigger
- **Can block?** — whether `exit 2` stops the action
- **Matcher** — what the matcher field filters on (if supported)
- **Input fields** — what the hook receives beyond the common fields
- **Practical use** — what you'd actually use it for

**Common fields present in every hook's stdin JSON:**
```json
{
  "session_id": "abc123",
  "prompt_id": "550e8400-...",
  "transcript_path": "/path/to/transcript.jsonl",
  "cwd": "/path/to/project",
  "permission_mode": "default",
  "hook_event_name": "PreToolUse",
  "effort": { "level": "medium" }
}
```
When inside a subagent, also: `agent_id` and `agent_type`.

---

## Exit Code Behavior (applies to all events)

| Exit code | Effect |
|---|---|
| `0` | Success — stdout parsed as JSON for structured control |
| `2` | **Blocking** — stderr fed to Claude as error; blocks the action |
| `1` or other | **Non-blocking** — action proceeds; transcript shows a hook error notice |

**Critical**: `exit 1` does NOT block. Only `exit 2` blocks. This is the most common mistake.

**JSON and exit codes are mutually exclusive**: structured JSON output (allow/deny/context injection) only works on exit 0. If you exit 2, all stdout is ignored.

**WorktreeCreate exception**: any non-zero exit (not just 2) fails worktree creation.

---

## Per-Session Events

These fire at session lifecycle boundaries.

---

### ★ SessionStart — Warm-Start Context Injection

**Category**: Per-Session | **★ Tier 1 — Ready to implement**

**When it fires**: Session begins or resumes. Fires before any user input.

**Can block?**: No — shows error in transcript; session proceeds.

**Matcher**: Session startup type: `startup`, `resume`, `clear`, `compact`, `fork`. Use `startup` for fresh starts only; omit matcher to fire on all session types.

**Additional input fields**: `source` (the startup type string).

**Use case**: Load engagement context docs into Claude's context window automatically at session start. Eliminates the need to manually run `/brief` or describe the project each session.

**Key behaviors**:
- `additionalContext` injected here appears before the first user prompt
- `initialUserMessage` can set the first message automatically (e.g., `"git status"`)
- `watchPaths` can register file paths for `FileChanged` hooks
- `sessionTitle` sets the session title in the UI
- `reloadSkills` forces skills to reload
- On `--resume`, hook re-runs with `source: "resume"` so dynamic values (branch, CI status) stay fresh
- `additionalContext` limit: 10,000 characters; excess saved to temp file

**Starter script**: `scripts/session-start.sh`

**Common configuration**:
```json
{
  "hooks": {
    "SessionStart": [{
      "matcher": "startup",
      "hooks": [{
        "type": "command",
        "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/session-start.sh",
        "args": [],
        "timeout": 30,
        "statusMessage": "Loading project context..."
      }]
    }]
  }
}
```

**Best practices**:
- Use `matcher: "startup"` unless you need context refresh on resume too
- Keep injected context under 8,000 chars to leave room for other hook injections
- Check for file existence before reading — gracefully degrade if reference files don't exist yet
- Load only the most actionable docs (ACTION-ITEMS.md, PROJECT-CONTEXT.md) — avoid loading everything

---

### ★ Stop — Doc-Update Reminder on Session Close

**Category**: Per-Turn | **★ Tier 1 — Ready to implement**

*(Listed here because it is the paired complement to SessionStart and most consulted alongside it)*

**When it fires**: Claude finishes responding. Fires at the end of every turn where Claude produces output.

**Can block?**: Yes — exit 2 or JSON `decision: "block"` prevents stopping; conversation continues.

**Matcher**: Not supported — fires on every stop.

**Additional input fields**: `last_assistant_message` (the last message Claude produced — use this instead of reading the transcript for the latest response).

**Use case**: Inject a reminder before every session close prompting Claude to update reference files. The conversation continues after the hook, so Claude reads the reminder and can act on it before the user sees the final turn.

**Key behaviors**:
- `additionalContext` at `Stop` is inserted at the end of the turn; conversation continues
- If you return `decision: "block"` with a `reason`, Claude stays in the loop and acts on the reason
- Do NOT phrase `additionalContext` as imperative commands — write factual statements to avoid prompt-injection defenses

**Factual vs imperative framing** (critical):
| Works | Avoid |
|---|---|
| `"ACTION-ITEMS.md was last updated 3 days ago"` | `"You must update ACTION-ITEMS.md"` |
| `"Tests are currently failing: auth.test.ts"` | `"Fix the failing tests before stopping"` |
| `"Session closing check: ACTION-ITEMS.md should reflect current state"` | `"Update all docs now"` |

**Starter script**: `scripts/session-close-check.sh`

**Common configuration**:
```json
{
  "hooks": {
    "Stop": [{
      "hooks": [{
        "type": "command",
        "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/session-close-check.sh",
        "args": [],
        "timeout": 10,
        "statusMessage": "Checking session close conditions..."
      }]
    }]
  }
}
```

**Best practices**:
- Keep this hook fast (timeout: 10) — it fires on every turn
- Do not run expensive checks (file reads, test runs) synchronously here; use `async: true` for those
- The doc-update reminder pattern is a nudge, not a gate — don't use `decision: "block"` for routine reminders; reserve blocking for hard conditions (tests failing)
- Pair with `/add-checkpoint` as a manual fallback for sessions that end abruptly

**Token expiry note**: If Claude Code is killed by token expiry, this hook does not fire. The `Stop` hook only fires on clean session ends. Use `/add-checkpoint` as the manual alternative in environments with frequent token expiry.

---

### Setup

**Category**: Per-Session

**When it fires**: When run with `--init-only`, `--init`, or `--maintenance` in `-p` mode.

**Can block?**: No.

**Matcher**: Same startup types as `SessionStart`.

**Use case**: Initial environment setup on first run. Creates directories, downloads dependencies, validates prerequisites. Typically not needed for standard toolkit usage.

---

### SessionEnd

**Category**: Per-Session

**When it fires**: Session terminates.

**Can block?**: No.

**Matcher**: Exit type — `clear`, `resume`, `logout`, `prompt_input_exit`, and others.

**Budget**: All `SessionEnd` hooks share a **1.5-second budget** (extendable to 60s with explicit `timeout` setting). If hooks take longer, they are killed. Keep teardown very fast or use `async`.

**Use case**: Cleanup on session exit — close temp files, log session duration, trigger CI/CD. Note that this suffers from the same unreliability as `Stop` on abrupt termination.

---

## Per-Turn Events

These fire once per user-Claude exchange.

---

### UserPromptSubmit

**Category**: Per-Turn

**When it fires**: User submits a prompt, before Claude processes it.

**Can block?**: Yes — exit 2 blocks the prompt and erases it.

**Matcher**: Not supported.

**Default timeout**: 30 seconds (lower than other events — keep these fast).

**Additional input fields**: `prompt` (the submitted prompt text).

**Use case**: Validate or augment user input before Claude sees it. Block specific prompt patterns. Inject additional context alongside the prompt. Can modify the prompt via `updatedHumanTurn` in JSON output.

**JSON output — modify the prompt**:
```json
{
  "hookSpecificOutput": {
    "hookEventName": "UserPromptSubmit",
    "updatedHumanTurn": "Modified prompt text here"
  }
}
```

---

### UserPromptExpansion

**Category**: Per-Turn

**When it fires**: User types a slash command that expands into a full prompt.

**Can block?**: Yes — blocks the expansion.

**Matcher**: Command name (e.g., `research`, `brief`).

**Use case**: Pre/post-processing when specific slash commands are invoked. Useful for injecting context alongside a command or auditing command usage.

---

### StopFailure

**Category**: Per-Turn

**When it fires**: Turn ends due to an API error.

**Can block?**: No — output and exit code are ignored entirely.

**Matcher**: Error type — `rate_limit`, `overloaded`, and others.

**Use case**: Logging, alerting, or fallback behavior on API errors. Cannot affect the flow since it fires after a failure.

---

## Agentic Loop Events

These fire on every tool call (except `EndConversation`). They are the highest-frequency hook events and the most impactful for controlling Claude's behavior.

---

### ★ PreToolUse — Guard Destructive Commands

**Category**: Agentic Loop | **★ Tier 1 — Ready to implement**

**When it fires**: Before a tool call executes. Fires for every tool call Claude makes.

**Can block?**: Yes — exit 2 or JSON `permissionDecision: "deny"` blocks the tool call.

**Matcher**: Tool name — `Bash`, `Edit`, `Write`, `Read`, `WebFetch`, `mcp__server__tool`, etc. Regex patterns supported.

**Additional input fields**:
```json
{
  "tool_name": "Bash",
  "tool_input": {
    "command": "rm -rf /tmp/build",
    "description": "Clean build artifacts",
    "timeout": 120000,
    "run_in_background": false
  },
  "tool_use_id": "toolu_01ABC123"
}
```

**Use case**: Block dangerous operations, enforce conventions, validate tool arguments before execution. The `rm -rf` guard is the single most universally recommended hook.

**Two blocking modes**:

*Structured deny (cleaner transcript)*:
```bash
jq -n '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "deny",
    permissionDecisionReason: "Blocked by toolkit policy"
  }
}'
exit 0
```

*Error block (simpler)*:
```bash
echo "Command blocked by policy" >&2
exit 2
```

**Rewrite tool arguments** (powerful — change what Claude is about to do):
```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "updatedInput": { "command": "echo safe-alternative" }
  }
}
```

**Starter script**: `scripts/guard-destructive.sh`

**Performance**: Use the `if` field pre-filter to avoid spawning the hook process for every tool call:
```json
"if": "Bash(rm *)"
```
The `if` filter is evaluated before the process spawns. It fails open on ambiguous commands — do not rely on `if` alone as a security boundary.

**Best practices**:
- Use structured JSON deny (exit 0) for permission flows; use exit 2 for hard errors
- Always read stdin before doing anything — `input=$(cat)` first
- Test with `echo '{...json...}' | bash script.sh; echo "Exit: $?"`
- Keep scope narrow — only block what you know is dangerous; fail open for ambiguous cases
- For `mcp__` tools, use regex matcher: `mcp__server__.*`

---

### PermissionRequest

**Category**: Agentic Loop

**When it fires**: Tool call needs a permission decision from the user.

**Can block?**: Yes — denies permission.

**Matcher**: Tool name.

**Use case**: Programmatically approve or deny permission requests without user interaction. Useful for automating permission grants for known-safe patterns in CI/CD or fully autonomous workflows.

**JSON output**:
```json
{
  "hookSpecificOutput": {
    "hookEventName": "PermissionRequest",
    "permissionDecision": "allow",
    "permissionDecisionReason": "Approved by policy"
  }
}
```

---

### PermissionDenied

**Category**: Agentic Loop

**When it fires**: Tool call denied by the auto mode classifier.

**Can block?**: No — fires after denial.

**Matcher**: Tool name.

**Use case**: Logging denied operations. Alerting on repeated denials. Providing Claude with context about why a denial occurred.

---

### PostToolUse

**Category**: Agentic Loop

**When it fires**: After a tool call succeeds.

**Can block?**: No — tool already ran.

**Matcher**: Tool name.

**Additional input fields**: `tool_name`, `tool_input`, `tool_use_id`, `tool_response` (what the tool returned).

**Use case**: Auto-format after file writes, run tests after edits, inject context about a file that was just written, sanitize/replace tool output Claude sees.

**Replace what Claude sees** (powerful):
```json
{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "updatedToolOutput": "Sanitized output here",
    "additionalContext": "Note: this is a generated file — edit src/schema.ts instead"
  }
}
```

**Common configuration for auto-format**:
```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Edit|Write",
      "hooks": [{
        "type": "command",
        "if": "Edit(src/**/*.ts)",
        "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/format.sh",
        "async": true
      }]
    }]
  }
}
```

---

### PostToolUseFailure

**Category**: Agentic Loop

**When it fires**: After a tool call fails.

**Can block?**: No.

**Matcher**: Tool name.

**Additional input fields**: `tool_name`, `tool_input`, `tool_use_id`, `error` (the failure reason).

**Use case**: Log tool failures for debugging. Inject additional context or recovery suggestions to Claude after a known failure mode.

---

### PostToolBatch

**Category**: Agentic Loop

**When it fires**: After a full batch of parallel tool calls resolves. Fires once per batch, not once per tool.

**Can block?**: Yes — exit 2 or `decision: "block"` stops the agentic loop before the next model call.

**Matcher**: Not supported.

**Use case**: Batch-level validation after a set of parallel operations completes. The most efficient place to run tests after multiple file writes — fires once, not once per file.

---

### SubagentStart

**Category**: Agentic Loop

**When it fires**: A subagent is spawned.

**Can block?**: No.

**Matcher**: Agent type (e.g., `Explore`, `general-purpose`).

**Additional input fields**: `agent_id`, `agent_type`.

**Use case**: Logging subagent spawning. Injecting context into a subagent before it runs. Note: `additionalContext` here appears before the subagent's first prompt.

---

### SubagentStop

**Category**: Agentic Loop

**When it fires**: A subagent finishes.

**Can block?**: Yes — prevents the subagent from stopping.

**Matcher**: Agent type.

**Use case**: Validation that the subagent completed its task before reporting back. Post-process subagent results.

---

### TaskCreated

**Category**: Agentic Loop

**When it fires**: A task is being created via `TaskCreate`.

**Can block?**: Yes — exit 2 rolls back task creation.

**Use case**: Audit/approve task creation in multi-agent workflows. Enforce naming conventions or scope limits on tasks.

---

### TaskCompleted

**Category**: Agentic Loop

**When it fires**: A task is being marked completed.

**Can block?**: Yes — prevents completion marking.

**Use case**: Validate completion criteria before allowing a task to close. Run acceptance checks.

---

## Async / Standalone Events

These fire in response to external triggers or system events. Most support `async: true`.

---

### ★ Notification — Desktop Alert on Session Idle

**Category**: Async / Standalone | **★ Tier 1 — Ready to implement**

**When it fires**: Claude Code sends a notification (e.g., when Claude is waiting for input after a long operation).

**Can block?**: No.

**Matcher**: Notification type.

**Additional input fields**: `message` (the notification text), `title`.

**Use case**: Desktop alerts when Claude is idle and waiting. Essential for long-running autonomous tasks where you've stepped away. Use `async: true` — this should never block.

**Starter script**: `scripts/notify.sh`

**macOS system notification variant** (alternative to terminal escape sequence):
```bash
#!/bin/bash
input=$(cat)
body=$(jq -r '.message // "Claude is waiting"' <<<"$input")
osascript -e "display notification \"$body\" with title \"Claude Code\""
```
Note: `osascript` spawns a subprocess and is slower than the escape sequence approach.

**Common configuration**:
```json
{
  "hooks": {
    "Notification": [{
      "hooks": [{
        "type": "command",
        "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/notify.sh",
        "async": true
      }]
    }]
  }
}
```

---

### MessageDisplay

**Category**: Async / Standalone

**When it fires**: Assistant message text is displayed.

**Can block?**: Yes — but has a 10-second timeout. Blocking display is unusual and should be avoided for performance.

**Matcher**: Not supported.

**Use case**: Real-time processing of Claude's output as it appears. Logging all assistant messages. Injecting UI overlays. Very rarely needed.

---

### TeammateIdle

**Category**: Async / Standalone

**When it fires**: An agent team teammate is about to go idle.

**Can block?**: Yes — prevents going idle.

**Matcher**: Agent type.

**Use case**: Multi-agent workflows where you need to keep a teammate active. Rarely needed outside of complex agent orchestration.

---

### InstructionsLoaded

**Category**: Async / Standalone

**When it fires**: A CLAUDE.md or rules file is loaded.

**Can block?**: No.

**Matcher**: File path or type.

**Additional input fields**: `filePath`, `instructionsType` (`project`, `user`, `subagent`), `content`.

**Use case**: Audit which instruction files are loaded per session. Log instruction file loading for debugging.

---

### ConfigChange

**Category**: Async / Standalone

**When it fires**: A config file changes during the session (Claude Code watches settings files).

**Can block?**: Yes — blocks the config change.

**Matcher**: Not specified.

**Use case**: Validate config changes before they take effect. Prevent unauthorized settings modifications in managed environments.

---

### CwdChanged

**Category**: Async / Standalone

**When it fires**: Working directory changes during the session.

**Can block?**: No.

**Additional input fields**: `oldCwd`, `newCwd`.

**Use case**: Reload environment variables or context when switching directories. Useful in monorepo setups where moving between packages requires different tooling.

---

### DirectoryAdded

**Category**: Async / Standalone

**When it fires**: A working directory is added mid-session.

**Can block?**: No.

**Use case**: Initialize new project context when a directory is added.

---

### FileChanged

**Category**: Async / Standalone

**When it fires**: A watched file changes on disk (requires `watchPaths` to be configured, typically via `SessionStart` hook output).

**Can block?**: No.

**Matcher**: Literal filenames to watch.

**Additional input fields**: `filePath`, `changeType`.

**Use case**: Reload `.env` on change. Invalidate cached state when config files update. Trigger re-analysis when source files change externally.

**Common configuration**:
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

---

### WorktreeCreate

**Category**: Async / Standalone

**When it fires**: A worktree is being created.

**Can block?**: Yes — **any non-zero exit** (not just exit 2) fails worktree creation. This is unique among all hook events.

**Use case**: Validate worktree creation. Set up per-worktree environment.

---

### WorktreeRemove

**Category**: Async / Standalone

**When it fires**: A worktree is being removed.

**Can block?**: No.

**Use case**: Cleanup per-worktree state. Log worktree lifecycle events.

---

### PreCompact

**Category**: Async / Standalone

**When it fires**: Before context compaction runs.

**Can block?**: Yes — blocks compaction.

**Use case**: Save state before compaction. Validate that important context won't be lost.

---

### PostCompact

**Category**: Async / Standalone

**When it fires**: After context compaction completes.

**Can block?**: No.

**Use case**: Reload context after compaction. Inject fresh context docs that may have been compacted away.

---

### Elicitation

**Category**: Async / Standalone

**When it fires**: An MCP server requests user input.

**Can block?**: Yes — denies the elicitation.

**Matcher**: MCP server name.

**Use case**: Programmatically handle MCP elicitations without user interaction. Approve or deny input requests from MCP servers.

---

### ElicitationResult

**Category**: Async / Standalone

**When it fires**: User responds to an MCP elicitation.

**Can block?**: Yes — blocks the response.

**Matcher**: MCP server name.

**Use case**: Validate or modify user responses to MCP input requests before they're passed to the server.

---

## Quick Reference: All 30 Events

| Event | Category | Can Block? | Common Use |
|---|---|---|---|
| ★ `SessionStart` | Per-Session | No | Context injection at session start |
| `Setup` | Per-Session | No | First-run initialization |
| `SessionEnd` | Per-Session | No | Cleanup (1.5s budget) |
| `UserPromptSubmit` | Per-Turn | Yes | Validate/modify user input |
| `UserPromptExpansion` | Per-Turn | Yes | Pre-process slash command expansions |
| ★ `Stop` | Per-Turn | Yes | Doc-update reminder; stop-if-failing guard |
| `StopFailure` | Per-Turn | No | Log API errors |
| ★ `PreToolUse` | Agentic Loop | Yes | Block dangerous commands |
| `PermissionRequest` | Agentic Loop | Yes | Programmatic permission decisions |
| `PermissionDenied` | Agentic Loop | No | Log denied operations |
| `PostToolUse` | Agentic Loop | No | Auto-format, test run, output injection |
| `PostToolUseFailure` | Agentic Loop | No | Log and recover from tool failures |
| `PostToolBatch` | Agentic Loop | Yes | Batch validation after parallel tool calls |
| `SubagentStart` | Agentic Loop | No | Log/inject context into subagents |
| `SubagentStop` | Agentic Loop | Yes | Validate subagent completion |
| `TaskCreated` | Agentic Loop | Yes | Audit task creation |
| `TaskCompleted` | Agentic Loop | Yes | Validate completion criteria |
| ★ `Notification` | Async | No | Desktop alerts when idle |
| `MessageDisplay` | Async | Yes (10s) | Real-time output processing |
| `TeammateIdle` | Async | Yes | Keep team agents active |
| `InstructionsLoaded` | Async | No | Audit instruction file loading |
| `ConfigChange` | Async | Yes | Validate config changes |
| `CwdChanged` | Async | No | Reload env on directory change |
| `DirectoryAdded` | Async | No | Initialize new directory context |
| `FileChanged` | Async | No | React to file changes on disk |
| `WorktreeCreate` | Async | Yes (any non-zero) | Validate worktree creation |
| `WorktreeRemove` | Async | No | Cleanup worktree state |
| `PreCompact` | Async | Yes | Preserve state before compaction |
| `PostCompact` | Async | No | Reload context after compaction |
| `Elicitation` | Async | Yes | Handle MCP input requests |
| `ElicitationResult` | Async | Yes | Validate MCP responses |
