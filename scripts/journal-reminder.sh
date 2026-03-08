#!/usr/bin/env bash
# journal-reminder.sh — PreToolUse hook (matcher: Edit|Write|NotebookEdit)
# Prints a contextual reminder to update journal.md when editing project files.
# Non-blocking (exit 0) — the Stop hook in ai-brain SKILL.md remains as hard enforcement.

INPUT=$(cat)

# Skip if editing ai-brain files (journal.md itself, known_issues.md, etc.)
echo "$INPUT" | grep -q 'ai-brain' && exit 0

# Contextual reminder — appears in tool result while AI is still composing
echo "📋 Also update journal.md in this same response (ai-brain write-back)."
exit 0
