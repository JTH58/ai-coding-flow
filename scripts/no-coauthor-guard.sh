#!/usr/bin/env bash
# no-coauthor-guard.sh — PreToolUse hook (matcher: Bash)
# Blocks git commit commands that contain Co-Authored-By trailers.
# Rule source: git-workflow SKILL.md § Strict Prohibitions

INPUT=$(cat)

# Only check git commit commands
echo "$INPUT" | grep -q 'git commit' || exit 0

# Block if Co-Authored-By is present (case insensitive)
if echo "$INPUT" | grep -qi 'co-authored-by'; then
  echo "BLOCKED: Co-Authored-By trailers are forbidden per git-workflow rules."
  echo "Commit under the user's authorship only. Remove the Co-Authored-By line."
  exit 2
fi

exit 0
