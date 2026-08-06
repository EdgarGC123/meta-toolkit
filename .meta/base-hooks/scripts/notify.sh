#!/bin/bash
# notify.sh — Notification hook (async: true)
# Sends a desktop notification when Claude Code sends a notification event.
# Useful for long-running tasks where you've stepped away.
#
# Two approaches are provided — use one based on your terminal/OS setup:
#   1. Terminal escape sequence (faster, works in iTerm2 and most modern terminals)
#   2. macOS osascript (system notification, works everywhere on macOS but slower)
#
# Prerequisites: jq must be on PATH. Check: which jq

input=$(cat)
body=$(jq -r '.message // "Claude Code needs your attention"' <<<"$input")
title=$(jq -r '.title // "Claude Code"' <<<"$input")

# Approach 1: Terminal escape sequence (recommended — no subprocess)
seq=$(printf '\033]777;notify;%s;%s\007' "$title" "$body")
jq -nc --arg seq "$seq" '{terminalSequence: $seq}'

# Approach 2: macOS system notification (uncomment to use instead of approach 1)
# osascript -e "display notification \"$body\" with title \"$title\"" 2>/dev/null || true
# exit 0
