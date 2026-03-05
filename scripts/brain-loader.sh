#!/usr/bin/env bash
# brain-loader.sh — SessionStart hook for Claude Code
# Outputs tiered Brain data into context.
# AI sees "=== AI BRAIN ===" marker and skips manual loading.

set -euo pipefail

PROJECT_NAME=$(basename "$PWD")
BRAIN_ROOT="$(dirname "$PWD")/ai-brain"

# No Brain repo → silent exit
[[ -d "$BRAIN_ROOT" ]] || exit 0

# No project Brain → silent exit (new project, not yet initialized)
[[ -d "$BRAIN_ROOT/$PROJECT_NAME" ]] || exit 0

echo "=== AI BRAIN: $PROJECT_NAME ==="
echo ""

# --- Tier 1: MUST READ (full text) ---
echo "--- MUST READ ---"
echo ""
for f in architecture_decisions.md known_issues.md; do
  if [[ -f "$BRAIN_ROOT/$PROJECT_NAME/$f" ]]; then
    echo "## $f"
    echo ""
    cat "$BRAIN_ROOT/$PROJECT_NAME/$f"
    echo ""
  fi
done

# --- Tier 2: AVAILABLE (read when needed) ---
echo "--- AVAILABLE (read when needed) ---"
echo ""
for f in todo.md journal.md; do
  [[ -f "$BRAIN_ROOT/$PROJECT_NAME/$f" ]] && echo "- \$BRAIN_ROOT/$PROJECT_NAME/$f"
done
[[ -f "$BRAIN_ROOT/_common/skill-experience.md" ]] && echo "- \$BRAIN_ROOT/_common/skill-experience.md"
echo ""

# --- Tier 3: ON DEMAND ---
echo "--- ON DEMAND ---"
echo ""
for f in "$BRAIN_ROOT/_common/"*.md; do
  [[ -f "$f" ]] || continue
  name=$(basename "$f")
  # Skip files loaded elsewhere or infrastructure-only
  case "$name" in
    SCHEMA.md|skill-experience.md) continue ;;
  esac
  echo "- \$BRAIN_ROOT/_common/$name"
done
echo ""

echo "=== END AI BRAIN ==="
echo ""
echo "Brain loaded. Respond to user FIRST before using tools."

# Create lock file — brain-gate.sh will block the first tool call
touch "/tmp/claude-brain-lock-${PROJECT_NAME}"

# Debug trace (persistent) — verify loader actually ran
echo "$(date '+%Y-%m-%d %H:%M:%S') brain-loader: $PROJECT_NAME" >> "/tmp/claude-brain-debug.log"
