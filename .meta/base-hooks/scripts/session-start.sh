#!/bin/bash
# session-start.sh — SessionStart hook
# Loads engagement context docs into Claude's context window at session start.
# Fires on fresh starts (matcher: "startup"). Eliminates needing to manually run /brief.
#
# Prerequisites: jq must be on PATH. Check: which jq

PROJECT_DIR="${CLAUDE_PROJECT_DIR}"
context=""

# Load whatever context docs exist — gracefully skip any that are missing
for f in \
  "$PROJECT_DIR/docs/PROJECT-CONTEXT.md" \
  "$PROJECT_DIR/docs/ACTION-ITEMS.md"; do
  if [ -f "$f" ]; then
    context="$context

---

$(cat "$f")"
  fi
done

# Optionally load reference files if they exist (codebase maps for existing-app toolkits)
for ref_dir in "$PROJECT_DIR/reference/"*/; do
  for ref_file in "$ref_dir"APP-CONTEXT.md "$ref_dir"ARCHITECTURE.md; do
    if [ -f "$ref_file" ] && [ -s "$ref_file" ]; then
      context="$context

---

$(cat "$ref_file")"
    fi
  done
done

# Only inject if there is something to say
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
