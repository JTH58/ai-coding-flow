#!/usr/bin/env bash
# journal-reminder.sh — PreToolUse hook (matcher: Edit|Write|NotebookEdit)
# Prints a mandatory reminder to update journal.md when editing project files.
# Non-blocking (exit 0) — but uses strong language to prevent skipping.

INPUT=$(cat)

# Skip if editing ai-brain files (journal.md itself, known_issues.md, etc.)
echo "$INPUT" | grep -q 'ai-brain' && exit 0

# Mandatory reminder — appears in tool result while AI is still composing
cat <<'MSG'
⚠️ MANDATORY: You MUST update journal.md BEFORE presenting results to the user.
This is part of the verification loop: WRITE → TEST → CROSS-CHECK → JOURNAL → STAMP → PRESENT.
Do NOT skip this. Do NOT defer it. Edit journal.md in the SAME response as this code change.
MSG
exit 0
