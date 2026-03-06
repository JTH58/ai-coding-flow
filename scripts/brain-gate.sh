#!/usr/bin/env bash
# brain-gate.sh — PreToolUse hook for Claude Code
# Forces AI to produce a text response before the first tool call.
# Claude Code exclusive — non-Claude-Code environments rely on prompt-level instructions.

PROJECT_NAME=$(basename "$PWD")
LOCK="/tmp/ai-brain-lock-${PROJECT_NAME}"

if [[ -f "$LOCK" ]]; then
  rm "$LOCK"
  echo "BLOCKED: Brain is loaded but you have not responded to the user yet."
  echo "Output your text response FIRST, then use tools."
  echo "$(date '+%Y-%m-%d %H:%M:%S') brain-gate: BLOCKED $PROJECT_NAME" >> "/tmp/claude-brain-debug.log"
  exit 2
fi

exit 0
