#!/bin/bash
# session-close-check.sh — Stop hook
# Injects a doc-update reminder into Claude's context at the end of every turn.
# The conversation continues after this fires — Claude reads the reminder and acts on it.
#
# Note: this hook fires on every turn end, not just on session close.
# It is a nudge, not a gate. Claude will act on the reminder before responding.
#
# Important: write additionalContext as factual statements, not imperatives.
# "ACTION-ITEMS.md should reflect current state" works.
# "You must update ACTION-ITEMS.md" can trigger prompt-injection defenses.
#
# Prerequisites: jq must be on PATH. Check: which jq

# Optional: check for a disable flag
if [ "${CLAUDE_HOOKS_DISABLED:-}" = "1" ] || [ -f "${CLAUDE_PROJECT_DIR}/.hooks-paused" ]; then
  exit 0
fi

input=$(cat)

jq -n '{
  hookSpecificOutput: {
    hookEventName: "Stop",
    additionalContext: "Session closing check: ACTION-ITEMS.md should reflect current state, including any blockers, completed work, and next steps. If new codebase areas were explored this session, APP-CONTEXT.md should capture what was found. If anything was deferred or left unresolved, it belongs in ACTION-ITEMS.md."
  }
}'
exit 0
