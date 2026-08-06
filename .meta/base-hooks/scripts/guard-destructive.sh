#!/bin/bash
# guard-destructive.sh — PreToolUse hook (matcher: Bash, if: "Bash(rm *)")
# Blocks rm -rf targeting root/home directories and force pushes to main/master.
#
# Two blocking modes are shown:
#   - Structured JSON deny (exit 0): cleaner transcript, reason shown as permission decision
#   - Error block (exit 2): simpler, stderr shown to Claude as an error
#
# The `if: "Bash(rm *)"` pre-filter in settings.json prevents this script from
# spawning for every Bash call. Only rm commands reach this script.
#
# Prerequisites: jq must be on PATH. Check: which jq

# Optional: check for a disable flag
if [ "${CLAUDE_HOOKS_DISABLED:-}" = "1" ] || [ -f "${CLAUDE_PROJECT_DIR}/.hooks-paused" ]; then
  exit 0
fi

input=$(cat)
command=$(jq -r '.tool_input.command // empty' <<<"$input")

if [ -z "$command" ]; then
  exit 0
fi

# Block rm -rf targeting root, home, or system directories
if echo "$command" | grep -qE 'rm\s+-rf\s+(/[^a-zA-Z]|/root|/home|/Users|~[^/]|~/[^a-zA-Z.]|~\s*$)'; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "Blocked: rm -rf targeting root or home directories is not allowed by toolkit policy. Use relative paths from the project root."
    }
  }'
  exit 0
fi

# Block force push to main or master (common accident on client engagements)
if echo "$command" | grep -qE 'git push.*(--force|-f).*(main|master)'; then
  echo "Force push to main/master blocked by toolkit policy. Use a feature branch and open a PR." >&2
  exit 2
fi

# All other rm commands pass through
exit 0
